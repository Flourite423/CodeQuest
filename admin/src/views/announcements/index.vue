<script setup lang="ts">
import { ref } from 'vue'
import { Plus } from '@element-plus/icons-vue'

const loading = ref(false)
const error = ref('')

const activeTab = ref('announcements')

const announcements = ref([
  { id: 1, title: '系统维护通知', audience: 'all', status: 'published', publishedAt: '2024-01-15', expiresAt: '2024-01-20' },
  { id: 2, title: '新功能上线', audience: 'all_learners', status: 'published', publishedAt: '2024-01-14', expiresAt: '2024-02-14' },
  { id: 3, title: '管理员会议', audience: 'all_admins', status: 'draft', publishedAt: '', expiresAt: '' },
])

const dialogVisible = ref(false)
const editingAnnouncement = ref<any>(null)

const handleEdit = (announcement: any) => {
  editingAnnouncement.value = { ...announcement }
  dialogVisible.value = true
}

const handleDelete = (_announcement: any) => {
  // TODO: Implement delete
}

const handleSave = () => {
  dialogVisible.value = false
  editingAnnouncement.value = null
}

const fetchData = async () => {
  loading.value = true
  error.value = ''
  try {
    // TODO: Replace with actual API call
    await new Promise(resolve => setTimeout(resolve, 500))
  } catch (e) {
    error.value = '加载数据失败，请重试'
  } finally {
    loading.value = false
  }
}

fetchData()
</script>

<template>
  <div class="announcements">
    <div class="header">
      <h1>公告与配置</h1>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="state-container">
      <el-skeleton :rows="5" animated />
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
        <!-- 公告管理 Tab -->
        <el-tab-pane label="公告管理" name="announcements">
          <div class="tab-header">
            <el-button type="primary" :icon="Plus">新建公告</el-button>
          </div>

          <!-- Empty State -->
          <div v-if="announcements.length === 0" class="state-container">
            <el-icon class="state-icon" color="#909399"><Document /></el-icon>
            <p class="state-text">暂无公告数据</p>
            <el-button type="primary" :icon="Plus">新建公告</el-button>
          </div>

          <el-table v-else :data="announcements" style="width: 100%">
            <el-table-column prop="id" label="公告ID" width="80" />
            <el-table-column prop="title" label="公告标题" />
            <el-table-column prop="audience" label="面向对象">
              <template #default="{ row }">
                <el-tag :type="row.audience === 'all' ? 'primary' : row.audience === 'all_learners' ? 'success' : 'warning'">
                  {{ row.audience === 'all' ? '全部用户' : row.audience === 'all_learners' ? '全部学员' : '全部管理员' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="status" label="状态">
              <template #default="{ row }">
                <el-tag :type="row.status === 'published' ? 'success' : 'info'">
                  {{ row.status === 'published' ? '已发布' : '草稿' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="publishedAt" label="发布时间" />
            <el-table-column prop="expiresAt" label="过期时间" />
            <el-table-column label="操作" width="150">
              <template #default="{ row }">
                <el-button size="small" @click="handleEdit(row)">编辑</el-button>
                <el-button size="small" type="danger" @click="handleDelete(row)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>

        <!-- 系统配置 Tab -->
        <el-tab-pane label="系统配置" name="config">
          <el-form label-width="120px">
            <el-form-item label="AI 每日调用上限">
              <el-input-number :min="1" :max="1000" />
            </el-form-item>

            <el-form-item label="经验值计算规则">
              <el-input type="textarea" rows="3" placeholder="请输入经验值计算规则" />
            </el-form-item>

            <el-form-item label="维护模式">
              <el-switch />
            </el-form-item>

            <el-form-item label="注册开关">
              <el-switch />
            </el-form-item>

            <el-form-item>
              <el-button type="primary">保存配置</el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>
      </el-tabs>
    </template>

    <el-dialog v-model="dialogVisible" title="编辑公告" width="500px">
      <el-form v-if="editingAnnouncement" :model="editingAnnouncement" label-width="100px">
        <el-form-item label="公告标题">
          <el-input v-model="editingAnnouncement.title" />
        </el-form-item>
        <el-form-item label="面向对象">
          <el-select v-model="editingAnnouncement.audience">
            <el-option label="全部用户" value="all" />
            <el-option label="全部学员" value="all_learners" />
            <el-option label="全部管理员" value="all_admins" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="editingAnnouncement.status">
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
.announcements {
  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;

    h1 {
      margin: 0;
    }
  }

  .tab-header {
    margin-bottom: 16px;
  }
}
</style>
