<script setup lang="ts">
import { ref } from 'vue'
import { Plus } from '@element-plus/icons-vue'

const courses = ref([
  { id: 1, title: 'Flutter 基础', description: '从零学习 Flutter', status: 'published', students: 234 },
  { id: 2, title: 'Rust 基础', description: '掌握 Rust 编程', status: 'published', students: 156 },
  { id: 3, title: 'Vue.js 进阶', description: '高级 Vue.js 模式', status: 'draft', students: 0 },
  { id: 4, title: '系统设计', description: '设计可扩展系统', status: 'published', students: 89 },
])

const dialogVisible = ref(false)
const editingCourse = ref<any>(null)

const handleEdit = (course: any) => {
  editingCourse.value = { ...course }
  dialogVisible.value = true
}

const handleDelete = (_course: any) => {
  // TODO: Implement delete
}

const handleSave = () => {
  dialogVisible.value = false
  editingCourse.value = null
}
</script>

<template>
  <div class="courses">
    <div class="header">
      <h1>课程管理</h1>
      <el-button type="primary" :icon="Plus">新建课程</el-button>
    </div>

    <el-table :data="courses" style="width: 100%">
      <el-table-column prop="id" label="课程ID" width="80" />
      <el-table-column prop="title" label="课程名称" />
      <el-table-column prop="description" label="课程简介" />
      <el-table-column prop="status" label="状态">
        <template #default="{ row }">
          <el-tag :type="row.status === 'published' ? 'success' : 'info'">
            {{ row.status === 'published' ? '已发布' : '草稿' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="students" label="学员数" width="100" />
      <el-table-column label="操作" width="150">
        <template #default="{ row }">
          <el-button size="small" @click="handleEdit(row)">编辑</el-button>
          <el-button size="small" type="danger" @click="handleDelete(row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="dialogVisible" title="编辑课程" width="500px">
      <el-form v-if="editingCourse" :model="editingCourse" label-width="100px">
        <el-form-item label="课程名称">
          <el-input v-model="editingCourse.title" />
        </el-form-item>
        <el-form-item label="课程简介">
          <el-input v-model="editingCourse.description" type="textarea" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="editingCourse.status">
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
.courses {
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
