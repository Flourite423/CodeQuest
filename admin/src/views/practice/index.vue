<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { Plus, Warning, Document } from '@element-plus/icons-vue'
import type { AdminExerciseListItem, ExerciseType, ExerciseStatus } from '@/types'
import { exerciseApi } from '@/api'
import { ElMessage, ElMessageBox } from 'element-plus'

const router = useRouter()
const loading = ref(false)
const error = ref('')
const forbidden = ref(false)
const sessionExpired = ref(false)

const exercises = ref<AdminExerciseListItem[]>([])

const filterType = ref('')
const filterDifficulty = ref('')

const filteredExercises = computed(() => {
  return exercises.value.filter(e => {
    const matchType = !filterType.value || e.type === filterType.value
    const matchDifficulty = !filterDifficulty.value || e.difficulty === filterDifficulty.value
    return matchType && matchDifficulty
  })
})

interface ExerciseForm {
  id?: string
  title: string
  type: ExerciseType
  difficulty: 'beginner' | 'intermediate'
  status: ExerciseStatus
}

const dialogVisible = ref(false)
const editingExercise = ref<ExerciseForm | null>(null)
const isCreating = ref(false)

const handleCreate = () => {
  isCreating.value = true
  editingExercise.value = {
    title: '',
    type: 'coding',
    difficulty: 'beginner',
    status: 'draft',
  }
  dialogVisible.value = true
}

const handleEdit = (exercise: AdminExerciseListItem) => {
  isCreating.value = false
  editingExercise.value = {
    id: exercise.id,
    title: exercise.title,
    type: exercise.type,
    difficulty: exercise.difficulty,
    status: exercise.status,
  }
  dialogVisible.value = true
}

const handleDelete = async (exercise: AdminExerciseListItem) => {
  try {
    await ElMessageBox.confirm('确定要删除该题目吗？', '确认删除', {
      confirmButtonText: '删除',
      cancelButtonText: '取消',
      type: 'warning',
    })
    await exerciseApi.delete(exercise.id)
    ElMessage.success('删除成功')
    fetchData()
  } catch (e: unknown) {
    if (e !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

const handleSave = async () => {
  if (!editingExercise.value) return
  
  try {
    if (isCreating.value) {
      const { id: _id, ...createData } = editingExercise.value
      await exerciseApi.create(createData as Omit<AdminExerciseListItem, 'id' | 'created_at' | 'updated_at'>)
      ElMessage.success('创建成功')
    } else {
      const { id, ...updateData } = editingExercise.value
      if (id) {
        await exerciseApi.update(id, updateData)
        ElMessage.success('更新成功')
      }
    }
    dialogVisible.value = false
    fetchData()
  } catch {
    ElMessage.error('保存失败')
  }
}

const getTypeLabel = (type: ExerciseType) => {
  const map: Record<ExerciseType, string> = {
    coding: '编程题',
    single_choice: '单选题',
  }
  return map[type] || type
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

const getStatusType = (status: ExerciseStatus) => {
  const map: Record<ExerciseStatus, string> = {
    draft: 'info',
    published: 'success',
  }
  return map[status] || 'info'
}

const getStatusLabel = (status: ExerciseStatus) => {
  const map: Record<ExerciseStatus, string> = {
    draft: '草稿',
    published: '已发布',
  }
  return map[status] || status
}

const fetchData = async () => {
  loading.value = true
  error.value = ''
  forbidden.value = false
  sessionExpired.value = false
  try {
    const res = await exerciseApi.list()
    exercises.value = res.data.items
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
  <div class="practice">
    <div class="header">
      <h1>题目管理</h1>
      <div class="header-actions">
        <el-select v-model="filterType" placeholder="类型" clearable style="width: 120px; margin-right: 12px;">
          <el-option label="编程题" value="coding" />
          <el-option label="单选题" value="single_choice" />
        </el-select>
        <el-select v-model="filterDifficulty" placeholder="难度" clearable style="width: 120px; margin-right: 12px;">
          <el-option label="初级" value="beginner" />
          <el-option label="中级" value="intermediate" />
        </el-select>
        <el-button type="primary" :icon="Plus" @click="handleCreate">新建题目</el-button>
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
    <div v-else-if="filteredExercises.length === 0" class="state-container">
      <el-icon class="state-icon" color="#909399"><Document /></el-icon>
      <p class="state-text">暂无题目数据</p>
      <el-button type="primary" :icon="Plus" @click="handleCreate">新建题目</el-button>
    </div>

    <!-- Content -->
    <template v-else>
      <el-table :data="filteredExercises" style="width: 100%" v-loading="loading">
        <el-table-column prop="title" label="题目名称" />
        <el-table-column prop="type" label="类型">
          <template #default="{ row }">
            <el-tag>{{ getTypeLabel(row.type) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="difficulty" label="难度">
          <template #default="{ row }">
            <el-tag :type="getDifficultyType(row.difficulty)">
              {{ getDifficultyLabel(row.difficulty) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">
              {{ getStatusLabel(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" label="创建时间" />
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button size="small" type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </template>

    <el-dialog v-model="dialogVisible" :title="isCreating ? '新建题目' : '编辑题目'" width="500px">
      <el-form v-if="editingExercise" :model="editingExercise" label-width="100px">
        <el-form-item label="题目名称">
          <el-input v-model="editingExercise.title" />
        </el-form-item>
        <el-form-item label="类型">
          <el-select v-model="editingExercise.type">
            <el-option label="编程题" value="coding" />
            <el-option label="单选题" value="single_choice" />
          </el-select>
        </el-form-item>
        <el-form-item label="难度">
          <el-select v-model="editingExercise.difficulty">
            <el-option label="初级" value="beginner" />
            <el-option label="中级" value="intermediate" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="editingExercise.status">
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
.practice {
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
