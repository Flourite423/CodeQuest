<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { Plus, Warning, Document } from '@element-plus/icons-vue'
import type { AdminChallengeListItem, ChallengeStatus } from '@/types'
import { challengeApi } from '@/api'
import { ElMessage, ElMessageBox } from 'element-plus'

const router = useRouter()
const loading = ref(false)
const error = ref('')
const forbidden = ref(false)
const sessionExpired = ref(false)

const challenges = ref<AdminChallengeListItem[]>([])

interface ChallengeForm {
  id?: string
  title: string
  difficulty: 'beginner' | 'intermediate'
  reward_xp: number
  status: 'draft' | 'published'
}

const dialogVisible = ref(false)
const editingChallenge = ref<ChallengeForm | null>(null)
const isCreating = ref(false)

const handleCreate = () => {
  isCreating.value = true
  editingChallenge.value = {
    title: '',
    difficulty: 'beginner',
    reward_xp: 0,
    status: 'draft',
  }
  dialogVisible.value = true
}

const handleEdit = (challenge: AdminChallengeListItem) => {
  isCreating.value = false
  editingChallenge.value = {
    id: challenge.id,
    title: challenge.title,
    difficulty: challenge.difficulty,
    reward_xp: challenge.reward_xp,
    status: challenge.status === 'archived' ? 'published' : challenge.status,
  }
  dialogVisible.value = true
}

const handleDelete = async (challenge: AdminChallengeListItem) => {
  try {
    await ElMessageBox.confirm('确定要删除该挑战吗？', '确认删除', {
      confirmButtonText: '删除',
      cancelButtonText: '取消',
      type: 'warning',
    })
    await challengeApi.delete(challenge.id)
    ElMessage.success('删除成功')
    fetchData()
  } catch (e: unknown) {
    if (e !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

const handleSave = async () => {
  if (!editingChallenge.value) return
  
  try {
    if (isCreating.value) {
      const { ...createData } = editingChallenge.value
      delete createData.id
      await challengeApi.create(createData as Omit<AdminChallengeListItem, 'id' | 'created_at' | 'updated_at'>)
      ElMessage.success('创建成功')
    } else {
      const { id, ...updateData } = editingChallenge.value
      if (id) {
        await challengeApi.update(id, updateData)
        ElMessage.success('更新成功')
      }
    }
    dialogVisible.value = false
    fetchData()
  } catch {
    ElMessage.error('保存失败')
  }
}

const getDifficultyType = (difficulty: string) => {
  const map: Record<string, string> = {
    beginner: 'success',
    intermediate: 'warning',
  }
  return map[difficulty] || 'info'
}

const getDifficultyLabel = (difficulty: string) => {
  const map: Record<string, string> = {
    beginner: '初级',
    intermediate: '中级',
  }
  return map[difficulty] || difficulty
}

const getStatusType = (status: ChallengeStatus) => {
  const map: Record<ChallengeStatus, string> = {
    draft: 'info',
    published: 'success',
    archived: 'warning',
  }
  return map[status] || 'info'
}

const getStatusLabel = (status: ChallengeStatus) => {
  const map: Record<ChallengeStatus, string> = {
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
    const res = await challengeApi.list()
    challenges.value = res.data.items
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
      <el-button
        type="primary"
        :icon="Plus"
        @click="handleCreate"
      >
        新建挑战
      </el-button>
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
      v-else-if="challenges.length === 0"
      class="state-container"
    >
      <el-icon
        class="state-icon"
        color="#909399"
      >
        <Document />
      </el-icon>
      <p class="state-text">
        暂无挑战数据
      </p>
      <el-button
        type="primary"
        :icon="Plus"
        @click="handleCreate"
      >
        新建挑战
      </el-button>
    </div>

    <!-- Content -->
    <template v-else>
      <el-table
        v-loading="loading"
        :data="challenges"
        style="width: 100%"
      >
        <el-table-column
          prop="title"
          label="挑战名称"
        />
        <el-table-column
          prop="difficulty"
          label="难度"
        >
          <template #default="{ row }">
            <el-tag :type="getDifficultyType(row.difficulty)">
              {{ getDifficultyLabel(row.difficulty) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column
          prop="reward_xp"
          label="奖励经验"
          width="100"
        />
        <el-table-column
          prop="status"
          label="状态"
        >
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">
              {{ getStatusLabel(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column
          label="操作"
          width="200"
        >
          <template #default="{ row }">
            <el-button
              size="small"
              @click="handleEdit(row)"
            >
              编辑
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
    </template>

    <el-dialog
      v-model="dialogVisible"
      :title="isCreating ? '新建挑战' : '编辑挑战'"
      width="500px"
    >
      <el-form
        v-if="editingChallenge"
        :model="editingChallenge"
        label-width="100px"
      >
        <el-form-item label="挑战名称">
          <el-input v-model="editingChallenge.title" />
        </el-form-item>
        <el-form-item label="难度">
          <el-select v-model="editingChallenge.difficulty">
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
        <el-form-item label="奖励经验">
          <el-input-number
            v-model="editingChallenge.reward_xp"
            :min="0"
          />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="editingChallenge.status">
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
