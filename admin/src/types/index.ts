export interface User {
  id: number
  username: string
  email: string
  role: 'admin' | 'learner'
  account_status: 'active' | 'suspended' | 'closed'
  xp: number
}

export interface Course {
  id: number
  title: string
  description: string
  status: 'published' | 'draft'
  students: number
  difficulty: 'easy' | 'medium' | 'hard'
  created_at: string
}

export interface Exercise {
  id: number
  title: string
  type: 'coding' | 'single_choice'
  difficulty: 'easy' | 'medium' | 'hard'
  chapter: string
  status: 'published' | 'draft'
}

export interface Challenge {
  id: number
  title: string
  difficulty: 'easy' | 'medium' | 'hard'
  reward_xp: number
  status: 'published' | 'draft' | 'archived'
  related_course_id?: number
}

export interface Announcement {
  id: number
  title: string
  audience: 'all' | 'all_learners' | 'all_admins'
  status: 'published' | 'draft'
  publishedAt: string
  expiresAt: string
}

export interface ModerationCase {
  id: number
  case_type: string
  target_id: string
  status: 'pending' | 'approved' | 'rejected'
  created_at: string
  reporter?: string
}
