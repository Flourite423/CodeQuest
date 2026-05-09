<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { Plus } from '@element-plus/icons-vue'
import type { Exercise } from '@/types'

const router = useRouter()
const loading = ref(false)
const error = ref('')
const forbidden = ref(false)
const sessionExpired = ref(false)

const exercises = ref<Exercise[]>([
  { id: 1, title: '变量声明', type: 'coding', difficulty: 'easy', chapter: '第一章', status: 'published' },
  { id: 2, title: '条件判断', type: 'single_choice', difficulty: 'medium', chapter: '第二章', status: 'published' },
  { id: 3, title: '循环结构', type: 'coding', difficulty: 'hard', chapter: '第三章', status: 'draft' },
])

const dialogVisible = ref(false)
const editingExercise = ref<Exercise | null>(null)

const handleEdit = (exercise: Exercise) => {
  editingExercise.value = { ...exercise }
  dialogVisible.value = true
}

const handleDelete = (exercise: Exercise) => {
  console.log('Delete exercise:', exercise.id)
}

const handleSave = () => {
  dialogVisible.value = false
  editingExercise.value = null
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
  <div class="practice">
    <div class="header">
      <h1>题目管理</h1>
      <el-button type="primary" :icon="Plus">新建题目</el-button>
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
    <div v-else-if="exercises.length === 0" class="state-container">
      <el-icon class="state-icon" color="#909399"><Document /></el-icon>
      <p class="state-text">暂无题目数据</p>
      <el-button type="primary" :icon="Plus">新建题目</el-button>
    </div>

    <!-- Content -->
    <template v-else>
      <el-table :data="exercises" style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="题目ID" width="80" />
        <el-table-column prop="title" label="题目标题" />
        <el-table-column prop="type" label="类型">
          <template #default="{ row }">
            <el-tag :type="row.type === 'coding' ? 'primary' : 'success'">
              {{ row.type === 'coding' ? '编码题' : '单选题' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="difficulty" label="难度">
          <template #default="{ row }">
            <el-tag :type="row.difficulty === 'easy' ? 'success' : row.difficulty === 'medium' ? 'warning' : 'danger'">
              {{ row.difficulty === 'easy' ? '简单' : row.difficulty === 'medium' ? '中等' : '困难' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="chapter" label="关联章节" />
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="row.status === 'published' ? 'success' : 'info'">
              {{ row.status === 'published' ? '已发布' : '草稿' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150">
          <template #default="{ row }">
            <el-button size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button size="small" type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </template>

    <el-dialog v-model="dialogVisible" title="编辑题目" width="500px">
      <el-form v-if="editingExercise" :model="editingExercise" label-width="100px">
        <el-form-item label="题目标题">
          <el-input v-model="editingExercise.title" />
        </el-form-item>
        <el-form-item label="类型">
          <el-select v-model="editingExercise.type">
            <el-option label="单选题" value="single_choice" />
            <el-option label="编码题" value="coding" />
          </el-select>
        </el-form-item>
        <el-form-item label="难度">
          <el-select v-model="editingExercise.difficulty">
            <el-option label="简单" value="easy" />
            <el-option label="中等" value="medium" />
            <el-option label="困难" value="hard" />
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
}
</style>
