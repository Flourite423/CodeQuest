<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { Plus } from '@element-plus/icons-vue'
import type { Challenge } from '@/types'

const router = useRouter()
const loading = ref(false)
const error = ref('')
const forbidden = ref(false)
const sessionExpired = ref(false)

const challenges = ref<Challenge[]>([
  { id: 1, title: '每日编程', difficulty: 'easy', reward_xp: 100, status: 'published', related_course_id: 1 },
  { id: 2, title: '每周挑战', difficulty: 'medium', reward_xp: 500, status: 'published', related_course_id: 2 },
  { id: 3, title: '月度马拉松', difficulty: 'hard', reward_xp: 2000, status: 'draft', related_course_id: 3 },
])

const dialogVisible = ref(false)
const editingChallenge = ref<Challenge | null>(null)

const handleEdit = (challenge: Challenge) => {
  editingChallenge.value = { ...challenge }
  dialogVisible.value = true
}

const handleDelete = (challenge: Challenge) => {
  console.log('Delete challenge:', challenge.id)
}

const handleSave = () => {
  dialogVisible.value = false
  editingChallenge.value = null
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
  <div class="challenges">
    <div class="header">
      <h1>挑战管理</h1>
      <el-button type="primary" :icon="Plus">新建挑战</el-button>
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
    <div v-else-if="challenges.length === 0" class="state-container">
      <el-icon class="state-icon" color="#909399"><Document /></el-icon>
      <p class="state-text">暂无挑战数据</p>
      <el-button type="primary" :icon="Plus">新建挑战</el-button>
    </div>

    <!-- Content -->
    <template v-else>
      <el-table :data="challenges" style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="挑战ID" width="80" />
        <el-table-column prop="title" label="挑战名称" />
        <el-table-column prop="difficulty" label="难度">
          <template #default="{ row }">
            <el-tag :type="row.difficulty === 'easy' ? 'success' : row.difficulty === 'medium' ? 'warning' : 'danger'">
              {{ row.difficulty === 'easy' ? '简单' : row.difficulty === 'medium' ? '中等' : '困难' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="reward_xp" label="奖励经验" width="100" />
        <el-table-column prop="related_course_id" label="关联课程" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.related_course_id">课程 {{ row.related_course_id }}</el-tag>
            <span v-else>--</span>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="row.status === 'published' ? 'success' : row.status === 'draft' ? 'info' : 'warning'">
              {{ row.status === 'published' ? '已发布' : row.status === 'draft' ? '草稿' : '已归档' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button size="small" type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </template>

    <el-dialog v-model="dialogVisible" title="编辑挑战" width="500px">
      <el-form v-if="editingChallenge" :model="editingChallenge" label-width="100px">
        <el-form-item label="挑战名称">
          <el-input v-model="editingChallenge.title" />
        </el-form-item>
        <el-form-item label="难度">
          <el-select v-model="editingChallenge.difficulty">
            <el-option label="简单" value="easy" />
            <el-option label="中等" value="medium" />
            <el-option label="困难" value="hard" />
          </el-select>
        </el-form-item>
        <el-form-item label="关联课程">
          <el-input-number v-model="editingChallenge.related_course_id" :min="0" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="editingChallenge.status">
            <el-option label="草稿" value="draft" />
            <el-option label="已发布" value="published" />
            <el-option label="已归档" value="archived" />
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
.challenges {
  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;

    h1 {
      margin: 0;
    }
  }
}
</style>
