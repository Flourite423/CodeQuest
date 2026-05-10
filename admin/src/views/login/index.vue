<script setup lang="ts">
import { reactive, ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { authApi } from '@/api/auth'
import { User, Lock } from '@element-plus/icons-vue'
import type { FormInstance, FormRules } from 'element-plus'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()
const loading = ref(false)
const sessionExpired = ref(false)
const loginError = ref('')

const formRef = ref<FormInstance>()
const form = reactive({
  email: '',
  password: '',
  remember: false,
})

const rules: FormRules = {
  email: [
    { required: true, message: '请输入邮箱地址', trigger: 'blur' },
    { type: 'email', message: '请输入有效的邮箱地址', trigger: 'blur' },
  ],
  password: [
    { required: true, message: '请输入登录密码', trigger: 'blur' },
    { min: 6, message: '密码长度至少6位', trigger: 'blur' },
  ],
}

onMounted(() => {
  if (route.query.expired === '1') {
    sessionExpired.value = true
  }
})

const handleLogin = async () => {
  if (!formRef.value) return

  try {
    await formRef.value.validate()
  } catch {
    return // validation failed
  }

  loading.value = true
  sessionExpired.value = false
  loginError.value = ''

  try {
    const res = await authApi.login({ email: form.email, password: form.password })
    authStore.setToken(res.data.access_token)
    authStore.setUser({ username: res.data.account.email, role: 'admin' })
    router.push('/')
  } catch (err: any) {
    const status = err.response?.status
    if (status === 401) {
      loginError.value = '邮箱或密码错误'
    } else if (status === 403) {
      loginError.value = '无权访问'
    } else if (status === 500) {
      loginError.value = '服务器错误，请稍后重试'
    } else {
      loginError.value = '登录失败，请稍后重试'
    }
    loading.value = false
  }
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

      <el-alert
        v-if="sessionExpired"
        title="登录已过期，请重新登录"
        type="warning"
        :closable="false"
        class="session-alert"
      />

      <el-alert
        v-if="loginError"
        :title="loginError"
        type="error"
        :closable="false"
        class="session-alert"
      />

      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-position="top"
        @submit.prevent="handleLogin"
      >
        <el-form-item label="邮箱地址" prop="email">
          <el-input
            v-model="form.email"
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
          <el-checkbox v-model="form.remember">记住登录状态</el-checkbox>
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

.session-alert {
  margin-bottom: 16px;
}

.login-button {
  width: 100%;
}
</style>
