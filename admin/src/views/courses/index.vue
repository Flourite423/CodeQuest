<script setup lang="ts">
import { ref } from 'vue'

const courses = ref([
  { id: 1, title: 'Flutter Basics', description: 'Learn Flutter from scratch', status: 'published', students: 234 },
  { id: 2, title: 'Rust Fundamentals', description: 'Master Rust programming', status: 'published', students: 156 },
  { id: 3, title: 'Vue.js Advanced', description: 'Advanced Vue.js patterns', status: 'draft', students: 0 },
  { id: 4, title: 'System Design', description: 'Design scalable systems', status: 'published', students: 89 },
])

const dialogVisible = ref(false)
const editingCourse = ref<any>(null)

const handleEdit = (course: any) => {
  editingCourse.value = { ...course }
  dialogVisible.value = true
}

const handleDelete = (course: any) => {
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
      <h1>Courses</h1>
      <el-button type="primary" :icon="Plus">Add Course</el-button>
    </div>

    <el-table :data="courses" style="width: 100%">
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="title" label="Title" />
      <el-table-column prop="description" label="Description" />
      <el-table-column prop="status" label="Status">
        <template #default="{ row }">
          <el-tag :type="row.status === 'published' ? 'success' : 'info'">
            {{ row.status }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="students" label="Students" width="100" />
      <el-table-column label="Actions" width="150">
        <template #default="{ row }">
          <el-button size="small" @click="handleEdit(row)">Edit</el-button>
          <el-button size="small" type="danger" @click="handleDelete(row)">Delete</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="dialogVisible" title="Edit Course" width="500px">
      <el-form v-if="editingCourse" :model="editingCourse" label-width="100px">
        <el-form-item label="Title">
          <el-input v-model="editingCourse.title" />
        </el-form-item>
        <el-form-item label="Description">
          <el-input v-model="editingCourse.description" type="textarea" />
        </el-form-item>
        <el-form-item label="Status">
          <el-select v-model="editingCourse.status">
            <el-option label="Draft" value="draft" />
            <el-option label="Published" value="published" />
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
