<script setup lang="ts">
import { ref } from 'vue'
import { Plus } from '@element-plus/icons-vue'

const challenges = ref([
  { id: 1, title: '每日编程', type: 'daily', difficulty: 'easy', xpReward: 100, status: 'active' },
  { id: 2, title: '每周挑战', type: 'weekly', difficulty: 'medium', xpReward: 500, status: 'active' },
  { id: 3, title: '月度马拉松', type: 'monthly', difficulty: 'hard', xpReward: 2000, status: 'upcoming' },
])

const dialogVisible = ref(false)
const editingChallenge = ref<any>(null)

const handleEdit = (challenge: any) => {
  editingChallenge.value = { ...challenge }
  dialogVisible.value = true
}

const handleSave = () => {
  dialogVisible.value = false
  editingChallenge.value = null
}
</script>

<template>
  <div class="challenges">
    <div class="header">
      <h1>挑战管理</h1>
      <el-button type="primary" :icon="Plus">新建挑战</el-button>
    </div>

    <el-table :data="challenges" style="width: 100%">
      <el-table-column prop="id" label="挑战ID" width="80" />
      <el-table-column prop="title" label="挑战名称" />
      <el-table-column prop="type" label="类型" />
      <el-table-column prop="difficulty" label="难度">
        <template #default="{ row }">
          <el-tag :type="row.difficulty === 'easy' ? 'success' : row.difficulty === 'medium' ? 'warning' : 'danger'">
            {{ row.difficulty === 'easy' ? '简单' : row.difficulty === 'medium' ? '中等' : '困难' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="xpReward" label="奖励经验" width="100" />
      <el-table-column prop="status" label="状态">
        <template #default="{ row }">
          <el-tag :type="row.status === 'active' ? 'success' : 'info'">
            {{ row.status === 'active' ? '进行中' : '即将开始' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="150">
        <template #default="{ row }">
          <el-button size="small" @click="handleEdit(row)">编辑</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="dialogVisible" title="编辑挑战" width="500px">
      <el-form v-if="editingChallenge" :model="editingChallenge" label-width="100px">
        <el-form-item label="挑战名称">
          <el-input v-model="editingChallenge.title" />
        </el-form-item>
        <el-form-item label="类型">
          <el-select v-model="editingChallenge.type">
            <el-option label="每日" value="daily" />
            <el-option label="每周" value="weekly" />
            <el-option label="每月" value="monthly" />
          </el-select>
        </el-form-item>
        <el-form-item label="难度">
          <el-select v-model="editingChallenge.difficulty">
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
