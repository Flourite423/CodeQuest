<script setup lang="ts">
import { ref } from 'vue'

const challenges = ref([
  { id: 1, title: 'Daily Coding', type: 'daily', difficulty: 'easy', xpReward: 100, status: 'active' },
  { id: 2, title: 'Weekly Challenge', type: 'weekly', difficulty: 'medium', xpReward: 500, status: 'active' },
  { id: 3, title: 'Monthly Marathon', type: 'monthly', difficulty: 'hard', xpReward: 2000, status: 'upcoming' },
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
      <h1>Challenges</h1>
      <el-button type="primary" :icon="Plus">Add Challenge</el-button>
    </div>

    <el-table :data="challenges" style="width: 100%">
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="title" label="Title" />
      <el-table-column prop="type" label="Type" />
      <el-table-column prop="difficulty" label="Difficulty">
        <template #default="{ row }">
          <el-tag :type="row.difficulty === 'easy' ? 'success' : row.difficulty === 'medium' ? 'warning' : 'danger'">
            {{ row.difficulty }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="xpReward" label="XP Reward" width="100" />
      <el-table-column prop="status" label="Status">
        <template #default="{ row }">
          <el-tag :type="row.status === 'active' ? 'success' : 'info'">
            {{ row.status }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="Actions" width="150">
        <template #default="{ row }">
          <el-button size="small" @click="handleEdit(row)">Edit</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="dialogVisible" title="Edit Challenge" width="500px">
      <el-form v-if="editingChallenge" :model="editingChallenge" label-width="100px">
        <el-form-item label="Title">
          <el-input v-model="editingChallenge.title" />
        </el-form-item>
        <el-form-item label="Type">
          <el-select v-model="editingChallenge.type">
            <el-option label="Daily" value="daily" />
            <el-option label="Weekly" value="weekly" />
            <el-option label="Monthly" value="monthly" />
          </el-select>
        </el-form-item>
        <el-form-item label="Difficulty">
          <el-select v-model="editingChallenge.difficulty">
            <el-option label="Easy" value="easy" />
            <el-option label="Medium" value="medium" />
            <el-option label="Hard" value="hard" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">Cancel</el-button>
        <el-button type="primary" @click="handleSave">Save</el-button>
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
