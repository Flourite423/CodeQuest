<script setup lang="ts">
import { ref } from 'vue'

const leaderboard = ref([
  { rank: 1, username: 'learner1', level: 20, xp: 50000, streak: 30 },
  { rank: 2, username: 'learner2', level: 18, xp: 45000, streak: 25 },
  { rank: 3, username: 'learner3', level: 17, xp: 42000, streak: 20 },
  { rank: 4, username: 'learner4', level: 15, xp: 38000, streak: 15 },
  { rank: 5, username: 'learner5', level: 14, xp: 35000, streak: 10 },
])
</script>

<template>
  <div class="leaderboard">
    <h1>Leaderboard</h1>

    <el-table :data="leaderboard" style="width: 100%">
      <el-table-column prop="rank" label="Rank" width="80">
        <template #default="{ row }">
          <el-tag v-if="row.rank <= 3" :type="row.rank === 1 ? 'warning' : row.rank === 2 ? 'info' : 'danger'">
            {{ row.rank }}
          </el-tag>
          <span v-else>{{ row.rank }}</span>
        </template>
      </el-table-column>
      <el-table-column prop="username" label="Username" />
      <el-table-column prop="level" label="Level" width="100" />
      <el-table-column prop="xp" label="XP" />
      <el-table-column prop="streak" label="Streak (days)" />
    </el-table>
  </div>
</template>

<style scoped lang="scss">
.leaderboard {
  h1 {
    margin-bottom: 24px;
  }
}
</style>
