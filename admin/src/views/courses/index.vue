<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { Plus, Search } from '@element-plus/icons-vue'
import type { Course } from '@/types'

const router = useRouter()
const loading = ref(false)
const error = ref('')
const forbidden = ref(false)
const sessionExpired = ref(false)

const courses = ref<Course[]>([
  { id: 1, title: 'Flutter 基础', description: '从零学习 Flutter', status: 'published', students: 234, difficulty: 'easy', created_at: '2024-01-01' },
  { id: 2, title: 'Rust 基础', description: '掌握 Rust 编程', status: 'published', students: 156, difficulty: 'medium', created_at: '2024-01-02' },
  { id: 3, title: 'Vue.js 进阶', description: '高级 Vue.js 模式', status: 'draft', students: 0, difficulty: 'hard', created_at: '2024-01-03' },
  { id: 4, title: '系统设计', description: '设计可扩展系统', status: 'published', students: 89, difficulty: 'medium', created_at: '2024-01-04' },
])

const searchQuery = ref('')

const filteredCourses = computed(() => {
  if (!searchQuery.value) return courses.value
  return courses.value.filter(c =>
    c.title.includes(searchQuery.value) ||
    c.description.includes(searchQuery.value)
  )
})

const dialogVisible = ref(false)
const editingCourse = ref<Course | null>(null)

const handleEdit = (course: Course) => {
  editingCourse.value = { ...course }
  dialogVisible.value = true
}

const handleDelete = (course: Course) => {
  console.log('Delete course:', course.id)
}

const handleArchive = (course: Course) => {
  course.status = 'archived' as 'published' | 'draft'
}

const handleSave = () => {
  dialogVisible.value = false
  editingCourse.value = null
}

const fetchData = async () => {
  loading.value = true
  error.value = ''
  forbidden.value = false
  sessionExpired.value = false
  try {
    await new Promise(resolve => setTimeout(resolve, 500))
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
        />
        <el-button type="primary" :icon="Plus">新建课程</el-button>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="state-container">
      <el-skeleton :rows="5" animated />
    </div>

    <!-- Forbidden State -->
    <div v-else-if="forbidden" class="state-container">
      <el-icon class="state-icon" color="#F56C6C"><Warning /></el-icon>
      <p class="state-text">无权访问</p>
    </div>

    <!-- Session Expired State -->
    <div v-else-if="sessionExpired" class="state-container">
      <el-icon class="state-icon" color="#E6A23C"><Warning /></el-icon>
      <p class="state-text">登录已过期，请重新登录</p>
      <p class="state-subtext">正在跳转到登录页...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="state-container">
      <el-icon class="state-icon" color="#F56C6C"><Warning /></el-icon>
      <p class="state-text">{{ error }}</p>
      <el-button type="primary" @click="fetchData">重试</el-button>
    </div>

    <!-- Empty State -->
    <div v-else-if="filteredCourses.length === 0" class="state-container">
      <el-icon class="state-icon" color="#909399"><Document /></el-icon>
      <p class="state-text">暂无课程数据</p>
      <el-button type="primary" :icon="Plus">新建课程</el-button>
    </div>

    <!-- Content -->
    <template v-else>
      <el-table :data="filteredCourses" style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="课程ID" width="80" />
        <el-table-column prop="title" label="课程名称" />
        <el-table-column prop="description" label="课程简介" />
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="row.status === 'published' ? 'success' : 'info'">
              {{ row.status === 'published' ? '已发布' : '草稿' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="students" label="学员数" width="100" />
        <el-table-column prop="created_at" label="创建时间" />
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button size="small" type="warning" @click="handleArchive(row)">归档</el-button>
            <el-button size="small" type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </template>

    <el-dialog v-model="dialogVisible" title="编辑课程" width="500px">
      <el-form v-if="editingCourse" :model="editingCourse" label-width="100px">
        <el-form-item label="课程名称">
          <el-input v-model="editingCourse.title" />
        </el-form-item>
        <el-form-item label="课程简介">
          <el-input v-model="editingCourse.description" type="textarea" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="editingCourse.status">
            <el-option label="草稿" value="draft" />
            <el-option label="已发布" value="published" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSave">保存</el-button>
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
}
</style>
