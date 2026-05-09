<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { User, Lock } from '@element-plus/icons-vue'
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
    { required: true, message: '请输入邮箱地址', trigger: 'blur' },
  ],
  password: [
    { required: true, message: '请输入登录密码', trigger: 'blur' },
    { min: 6, message: '密码长度至少6位', trigger: 'blur' },
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
          <h2>前端学习平台 - 管理后台</h2>
          <p>管理员登录</p>
        </div>
      </template>

      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-position="top"
        @submit.prevent="handleLogin"
      >
        <el-form-item label="邮箱地址" prop="username">
          <el-input
            v-model="form.username"
            placeholder="请输入邮箱地址"
            :prefix-icon="User"
          />
        </el-form-item>

        <el-form-item label="登录密码" prop="password">
          <el-input
            v-model="form.password"
            type="password"
            placeholder="请输入登录密码"
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
            登录
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
