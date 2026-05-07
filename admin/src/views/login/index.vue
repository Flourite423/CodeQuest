<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import type { FormInstance, FormRules } from 'element-plus'

const router = useRouter()
const authStore = useAuthStore()
const loading = ref(false)

const formRef = ref<FormInstance>()
const form = reactive({
  username: '',
  password: '',
})

const rules: FormRules = {
  username: [
    { required: true, message: 'Please input username', trigger: 'blur' },
  ],
  password: [
    { required: true, message: 'Please input password', trigger: 'blur' },
    { min: 6, message: 'Password length should be at least 6', trigger: 'blur' },
  ],
}

const handleLogin = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate((valid) => {
    if (valid) {
      loading.value = true
      setTimeout(() => {
        authStore.setToken('mock_admin_token')
        authStore.setUser({ username: form.username, role: 'admin' })
        loading.value = false
        router.push('/')
      }, 1000)
    }
  })
}
</script>

<template>
  <div class="login-container">
    <el-card class="login-card">
      <template #header>
        <div class="login-header">
          <h2>Learning Admin</h2>
          <p>Management System</p>
        </div>
      </template>

      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-position="top"
        @submit.prevent="handleLogin"
      >
        <el-form-item label="Username" prop="username">
          <el-input
            v-model="form.username"
            placeholder="Enter username"
            :prefix-icon="User"
          />
        </el-form-item>

        <el-form-item label="Password" prop="password">
          <el-input
            v-model="form.password"
            type="password"
            placeholder="Enter password"
            :prefix-icon="Lock"
            show-password
          />
        </el-form-item>

        <el-form-item>
          <el-button
            type="primary"
            :loading="loading"
            class="login-button"
            @click="handleLogin"
          >
            Sign In
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<style scoped lang="scss">
.login-container {
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #f0f2f5;
}

.login-card {
  width: 400px;
  
  .login-header {
    text-align: center;
    
    h2 {
      margin: 0;
      color: #303133;
    }
    
    p {
      margin: 8px 0 0;
      color: #909399;
    }
  }
}

.login-button {
  width: 100%;
}
</style>
