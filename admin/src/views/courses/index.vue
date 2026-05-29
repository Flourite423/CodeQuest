<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { Plus, Search, Warning, Document } from '@element-plus/icons-vue'
import { courseApi } from '@/api'
import type { AdminCourseListItem, CourseStatus } from '@/types'
import { ElMessage, ElMessageBox } from 'element-plus'

const router = useRouter()
const loading = ref(false)
const error = ref('')
const forbidden = ref(false)
const sessionExpired = ref(false)

const courses = ref<AdminCourseListItem[]>([])
const searchQuery = ref('')

const pagination = ref({
  page: 1,
  pageSize: 10,
  total: 0,
})

interface CourseForm {
  id?: string
  course_code: string
  title: string
  summary: string
  description: string
  cover_image_url: string
  difficulty: 'beginner' | 'intermediate'
  estimated_minutes: number
  status: 'draft' | 'published'
  sort_order: number
  content_version: number
}

const dialogVisible = ref(false)
const editingCourse = ref<CourseForm | null>(null)
const isCreating = ref(false)

const handleCreate = () => {
  isCreating.value = true
  editingCourse.value = {
    course_code: '',
    title: '',
    summary: '',
    description: '',
    cover_image_url: '',
    difficulty: 'beginner',
    estimated_minutes: 0,
    status: 'draft',
    sort_order: 0,
    content_version: 1,
  }
  dialogVisible.value = true
}

const handleEdit = (course: AdminCourseListItem) => {
  isCreating.value = false
  editingCourse.value = {
    id: course.id,
    course_code: course.course_code,
    title: course.title,
    summary: course.summary || '',
    description: (course as any).description || '',
    cover_image_url: (course as any).cover_image_url || '',
    difficulty: course.difficulty,
    estimated_minutes: course.estimated_minutes,
    status: course.status === 'archived' ? 'published' : course.status,
    sort_order: course.sort_order,
    content_version: course.content_version,
  }
  dialogVisible.value = true
}

const handleDelete = async (course: AdminCourseListItem) => {
  try {
    await ElMessageBox.confirm('确定要删除该课程吗？', '确认删除', {
      confirmButtonText: '删除',
      cancelButtonText: '取消',
      type: 'warning',
    })
    await courseApi.delete(course.id)
    ElMessage.success('删除成功')
    fetchData()
  } catch (e: unknown) {
    if (e !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

const handleArchive = async (course: AdminCourseListItem) => {
  try {
    await courseApi.update(course.id, {
      status: 'archived',
      content_version: course.content_version,
    })
    ElMessage.success('归档成功')
    fetchData()
  } catch {
    ElMessage.error('归档失败')
  }
}

const handleSave = async () => {
  if (!editingCourse.value) return
  
  try {
    if (isCreating.value) {
      await courseApi.create(editingCourse.value)
      ElMessage.success('创建成功')
    } else {
      const { id, ...updateData } = editingCourse.value
      if (id) {
        await courseApi.update(id, updateData)
        ElMessage.success('更新成功')
      }
    }
    dialogVisible.value = false
    fetchData()
  } catch {
    ElMessage.error('保存失败')
  }
}

const getStatusType = (status: CourseStatus) => {
  const map: Record<CourseStatus, string> = {
    draft: 'info',
    published: 'success',
    archived: 'warning',
  }
  return map[status] || 'info'
}

const getStatusLabel = (status: CourseStatus) => {
  const map: Record<CourseStatus, string> = {
    draft: '草稿',
    published: '已发布',
    archived: '已归档',
  }
  return map[status] || status
}

const fetchData = async () => {
  loading.value = true
  error.value = ''
  forbidden.value = false
  sessionExpired.value = false
  try {
    const params: Record<string, unknown> = {
      page: pagination.value.page,
      page_size: pagination.value.pageSize,
    }
    if (searchQuery.value) {
      params.search = searchQuery.value
    }
    const res = await courseApi.list(params)
    courses.value = res.data.items
    pagination.value.total = res.data.meta.total
  } catch (e: unknown) {
    if (e instanceof Error && e.message.includes('403')) {
      forbidden.value = true
    } else if (e instanceof Error && e.message.includes('401')) {
      sessionExpired.value = true
      setTimeout(() => {
        router.push('/login?expired=1')
      }, 2000)
    } else {
      error.value = '加载数据失败，请重试'
    }
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.value.page = 1
  fetchData()
}

fetchData()
</script>

<template>
  <div class="courses">
    <div class="header">
      <h1>课程管理</h1>
      <div class="header-actions">
        <el-input
          v-model="searchQuery"
          placeholder="搜索课程名称..."
          :prefix-icon="Search"
          style="width: 250px; margin-right: 12px;"
          @keyup.enter="handleSearch"
        />
        <el-button
          type="primary"
          :icon="Plus"
          @click="handleCreate"
        >
          新建课程
        </el-button>
      </div>
    </div>

    <!-- Loading State -->
    <div
      v-if="loading"
      class="state-container"
    >
      <el-skeleton
        :rows="5"
        animated
      />
    </div>

    <!-- Forbidden State -->
    <div
      v-else-if="forbidden"
      class="state-container"
    >
      <el-icon
        class="state-icon"
        color="#F56C6C"
      >
        <Warning />
      </el-icon>
      <p class="state-text">
        无权访问
      </p>
    </div>

    <!-- Session Expired State -->
    <div
      v-else-if="sessionExpired"
      class="state-container"
    >
      <el-icon
        class="state-icon"
        color="#E6A23C"
      >
        <Warning />
      </el-icon>
      <p class="state-text">
        登录已过期，请重新登录
      </p>
      <p class="state-subtext">
        正在跳转到登录页...
      </p>
    </div>

    <!-- Error State -->
    <div
      v-else-if="error"
      class="state-container"
    >
      <el-icon
        class="state-icon"
        color="#F56C6C"
      >
        <Warning />
      </el-icon>
      <p class="state-text">
        {{ error }}
      </p>
      <el-button
        type="primary"
        @click="fetchData"
      >
        重试
      </el-button>
    </div>

    <!-- Empty State -->
    <div
      v-else-if="courses.length === 0"
      class="state-container"
    >
      <el-icon
        class="state-icon"
        color="#909399"
      >
        <Document />
      </el-icon>
      <p class="state-text">
        暂无课程数据
      </p>
      <el-button
        type="primary"
        :icon="Plus"
        @click="handleCreate"
      >
        新建课程
      </el-button>
    </div>

    <!-- Content -->
    <template v-else>
      <el-table
        v-loading="loading"
        :data="courses"
        style="width: 100%"
      >
        <el-table-column
          prop="course_code"
          label="课程代码"
          width="120"
        />
        <el-table-column
          prop="title"
          label="课程名称"
        />
        <el-table-column
          prop="summary"
          label="课程简介"
          show-overflow-tooltip
        />
        <el-table-column
          prop="status"
          label="状态"
          width="100"
        >
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">
              {{ getStatusLabel(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column
          prop="difficulty"
          label="难度"
          width="100"
        >
          <template #default="{ row }">
            <el-tag :type="row.difficulty === 'beginner' ? 'success' : 'warning'">
              {{ row.difficulty === 'beginner' ? '初级' : '中级' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column
          prop="estimated_minutes"
          label="预计时长(分)"
          width="120"
        />
        <el-table-column
          prop="created_at"
          label="创建时间"
        />
        <el-table-column
          label="操作"
          width="250"
        >
          <template #default="{ row }">
            <el-button
              size="small"
              @click="handleEdit(row)"
            >
              编辑
            </el-button>
            <el-button 
              v-if="row.status !== 'archived'"
              size="small" 
              type="warning" 
              @click="handleArchive(row)"
            >
              归档
            </el-button>
            <el-button
              size="small"
              type="danger"
              @click="handleDelete(row)"
            >
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination">
        <el-pagination
          v-model:current-page="pagination.page"
          v-model:page-size="pagination.pageSize"
          :total="pagination.total"
          :page-sizes="[10, 20, 50]"
          layout="total, sizes, prev, pager, next"
          @current-change="fetchData"
          @size-change="fetchData"
        />
      </div>
    </template>

    <el-dialog
      v-model="dialogVisible"
      :title="isCreating ? '新建课程' : '编辑课程'"
      width="600px"
    >
      <el-form
        v-if="editingCourse"
        :model="editingCourse"
        label-width="100px"
      >
        <el-form-item label="课程代码">
          <el-input
            v-model="editingCourse.course_code"
            :disabled="!isCreating"
          />
        </el-form-item>
        <el-form-item label="课程名称">
          <el-input v-model="editingCourse.title" />
        </el-form-item>
        <el-form-item label="课程简介">
          <el-input
            v-model="editingCourse.summary"
            type="textarea"
            :rows="3"
          />
        </el-form-item>
        <el-form-item label="详细描述">
          <el-input
            v-model="editingCourse.description"
            type="textarea"
            :rows="5"
            placeholder="课程的详细描述，支持 Markdown 格式"
          />
        </el-form-item>
        <el-form-item label="封面图URL">
          <el-input
            v-model="editingCourse.cover_image_url"
            placeholder="https://example.com/cover.png"
          />
        </el-form-item>
        <el-form-item label="难度">
          <el-select v-model="editingCourse.difficulty">
            <el-option
              label="初级"
              value="beginner"
            />
            <el-option
              label="中级"
              value="intermediate"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="预计时长">
          <el-input-number
            v-model="editingCourse.estimated_minutes"
            :min="0"
          />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="editingCourse.status">
            <el-option
              label="草稿"
              value="draft"
            />
            <el-option
              label="已发布"
              value="published"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="editingCourse.sort_order" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">
          取消
        </el-button>
        <el-button
          type="primary"
          @click="handleSave"
        >
          保存
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped lang="scss">
.courses {
  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;

    h1 {
      margin: 0;
    }
  }

  .header-actions {
    display: flex;
    align-items: center;
  }

  .pagination {
    display: flex;
    justify-content: flex-end;
    margin-top: 16px;
  }
}
</style>
