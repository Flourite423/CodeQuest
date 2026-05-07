<script setup lang="ts">
import { reactive } from 'vue'

const settings = reactive({
  siteName: 'Learning App',
  maintenanceMode: false,
  allowRegistration: true,
  maxCoursesPerUser: 10,
  dailyChallengeTime: '09:00',
})

const handleSave = () => {
  // TODO: Save settings to backend
}
</script>

<template>
  <div class="settings">
    <h1>Settings</h1>

    <el-form :model="settings" label-width="200px">
      <el-form-item label="Site Name">
        <el-input v-model="settings.siteName" />
      </el-form-item>

      <el-form-item label="Maintenance Mode">
        <el-switch v-model="settings.maintenanceMode" />
      </el-form-item>

      <el-form-item label="Allow Registration">
        <el-switch v-model="settings.allowRegistration" />
      </el-form-item>

      <el-form-item label="Max Courses Per User">
        <el-input-number v-model="settings.maxCoursesPerUser" :min="1" :max="50" />
      </el-form-item>

      <el-form-item label="Daily Challenge Time">
        <el-time-picker v-model="settings.dailyChallengeTime" format="HH:mm" />
      </el-form-item>

      <el-form-item>
        <el-button type="primary" @click="handleSave">Save Settings</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<style scoped lang="scss">
.settings {
  h1 {
    margin-bottom: 24px;
  }
  
  .el-form {
    max-width: 600px;
  }
}
</style>
