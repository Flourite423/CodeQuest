<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { Plus, Warning } from '@element-plus/icons-vue'
import type { Announcement, AnnouncementStatus, AnnouncementAudience } from '@/types'
import { announcementApi } from '@/api'
import { ElMessage, ElMessageBox } from 'element-plus'

const router = useRouter()
const loading = ref(false)
const error = ref('')
const forbidden = ref(false)
const sessionExpired = ref(false)

const activeTab = ref('announcements')

const announcements = ref<Announcement[]>([])

interface AnnouncementForm {
  id?: string
  title: string
  body_markdown: string
  audience: AnnouncementAudience
  status: AnnouncementStatus
  published_at?: string | null
  expires_at?: string | null
}

const dialogVisible = ref(false)
const editingAnnouncement = ref<AnnouncementForm | null>(null)
const isCreating = ref(false)

const handleCreate = () => {
  isCreating.value = true
  editingAnnouncement.value = {
    title: '',
    body_markdown: '',
    audience: 'all',
    status: 'draft',
  }
  dialogVisible.value = true
}

const handleEdit = (announcement: Announcement) => {
  isCreating.value = false
  editingAnnouncement.value = {
    id: announcement.id,
    title: announcement.title,
    body_markdown: announcement.body_markdown,
    audience: announcement.audience,
    status: announcement.status,
    published_at: announcement.published_at,
    expires_at: announcement.expires_at,
  }
  dialogVisible.value = true
}

const handleDelete = async (announcement: Announcement) => {
  try {
    await ElMessageBox.confirm('确定要删除该公告吗？', '确认删除', {
      confirmButtonText: '删除',
      cancelButtonText: '取消',
      type: 'warning',
    })
    await announcementApi.delete(announcement.id)
    ElMessage.success('删除成功')
    fetchData()
  } catch (e: unknown) {
    if (e !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

const handleSave = async () => {
  if (!editingAnnouncement.value) return
  
  try {
    if (isCreating.value) {
      await announcementApi.create(editingAnnouncement.value)
      ElMessage.success('创建成功')
    } else {
      const { id, ...updateData } = editingAnnouncement.value
      if (id) {
        await announcementApi.update(id, updateData)
        ElMessage.success('更新成功')
      }
    }
    dialogVisible.value = false
    fetchData()
  } catch {
    ElMessage.error('保存失败')
  }
}

const getStatusType = (status: AnnouncementStatus) => {
  const map: Record<AnnouncementStatus, string> = {
    draft: 'info',
    published: 'success',
    expired: 'warning',
  }
  return map[status] || 'info'
}

const getStatusLabel = (status: AnnouncementStatus) => {
  const map: Record<AnnouncementStatus, string> = {
    draft: '草稿',
    published: '已发布',
    expired: '已过期',
  }
  return map[status] || status
}

const getAudienceLabel = (audience: AnnouncementAudience) => {
  const map: Record<AnnouncementAudience, string> = {
    all: '所有人',
    all_learners: '所有学习者',
    all_admins: '所有管理员',
  }
  return map[audience] || audience
}

const configForm = ref({
  site_name: '学习平台',
  contact_email: 'admin@example.com',
  max_courses_per_user: 10,
})

const fetchData = async () => {
  loading.value = true
  error.value = ''
  forbidden.value = false
  sessionExpired.value = false
  try {
    const res = await announcementApi.list()
    announcements.value = res.data.items
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
  <div class="announcements">
    <h1>公告与配置</h1>

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

    <!-- Content -->
    <template v-else>
      <el-tabs v-model="activeTab">
        <el-tab-pane label="公告管理" name="announcements">
          <div class="tab-header">
            <el-button type="primary" :icon="Plus" @click="handleCreate">发布公告</el-button>
          </div>

          <el-empty v-if="announcements.length === 0" description="暂无公告" />

          <el-table v-else :data="announcements" style="width: 100%">
            <el-table-column prop="title" label="标题" />
            <el-table-column prop="audience" label="受众">
              <template #default="{ row }">
                <el-tag>{{ getAudienceLabel(row.audience) }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="status" label="状态">
              <template #default="{ row }">
                <el-tag :type="getStatusType(row.status)">
                  {{ getStatusLabel(row.status) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="published_at" label="发布时间" />
            <el-table-column prop="expires_at" label="过期时间" />
            <el-table-column label="操作" width="200">
              <template #default="{ row }">
                <el-button size="small" @click="handleEdit(row)">编辑</el-button>
                <el-button size="small" type="danger" @click="handleDelete(row)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>

        <el-tab-pane label="系统配置" name="config">
          <el-form :model="configForm" label-width="150px">
            <el-form-item label="站点名称">
              <el-input v-model="configForm.site_name" />
            </el-form-item>
            <el-form-item label="联系邮箱">
              <el-input v-model="configForm.contact_email" />
            </el-form-item>
            <el-form-item label="每用户最大课程数">
              <el-input-number v-model="configForm.max_courses_per_user" :min="1" />
            </el-form-item>
            <el-form-item>
              <el-button type="primary">保存配置</el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>
      </el-tabs>
    </template>

    <el-dialog v-model="dialogVisible" :title="isCreating ? '发布公告' : '编辑公告'" width="600px">
      <el-form v-if="editingAnnouncement" :model="editingAnnouncement" label-width="100px">
        <el-form-item label="标题">
          <el-input v-model="editingAnnouncement.title" />
        </el-form-item>
        <el-form-item label="内容">
          <el-input v-model="editingAnnouncement.body_markdown" type="textarea" :rows="5" />
        </el-form-item>
        <el-form-item label="受众">
          <el-select v-model="editingAnnouncement.audience">
            <el-option label="所有人" value="all" />
            <el-option label="所有学习者" value="all_learners" />
            <el-option label="所有管理员" value="all_admins" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="editingAnnouncement.status">
            <el-option label="草稿" value="draft" />
            <el-option label="已发布" value="published" />
          </el-select>
        </el-form-item>
        <el-form-item label="发布时间">
          <el-date-picker v-model="editingAnnouncement.published_at" type="datetime" placeholder="选择发布时间" />
        </el-form-item>
        <el-form-item label="过期时间">
          <el-date-picker v-model="editingAnnouncement.expires_at" type="datetime" placeholder="选择过期时间" />
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
.announcements {
  h1 {
    margin-bottom: 24px;
  }

  .tab-header {
    margin-bottom: 16px;
  }
}
</style>
