// Types aligned with OpenAPI contract
// All IDs are UUID strings, all dates are ISO 8601 strings

// Common response envelope
export interface SuccessEnvelope<T> {
  code: string
  message: string
  data: T
}

// Pagination metadata
export interface PaginationMeta {
  page: number
  page_size: number
  total: number
  has_more: boolean
}

// Paginated response
export interface PaginatedResponse<T> {
  items: T[]
  meta: PaginationMeta
}

// Admin Course Types
export type CourseStatus = 'draft' | 'published' | 'archived'
export type CourseDifficulty = 'beginner' | 'intermediate'

export interface AdminCourseListItem {
  id: string
  course_code: string
  title: string
  summary?: string
  difficulty: CourseDifficulty
  estimated_minutes: number
  status: CourseStatus
  sort_order: number
  content_version: number
  created_by: string
  published_at?: string | null
  created_at: string
  updated_at: string
}

export interface AdminCourseDetail extends AdminCourseListItem {
  description?: string | null
  cover_image_url?: string | null
  chapters: Chapter[]
}

export interface AdminCourseCreateInput {
  course_code: string
  title: string
  summary: string
  description?: string | null
  cover_image_url?: string | null
  difficulty: CourseDifficulty
  estimated_minutes: number
  status: CourseStatus
  sort_order: number
  content_version: number
  published_at?: string | null
}

export interface AdminCourseUpdateInput {
  title?: string
  summary?: string
  description?: string | null
  cover_image_url?: string | null
  difficulty?: CourseDifficulty
  estimated_minutes?: number
  status?: CourseStatus
  sort_order?: number
  content_version: number
  published_at?: string | null
}

// Chapter Type
export interface Chapter {
  id: string
  course_id: string
  title: string
  sort_order: number
  status: CourseStatus
  created_at: string
  updated_at: string
}

// Exercise Types
export type ExerciseType = 'coding' | 'single_choice'
export type ExerciseStatus = 'draft' | 'published'

export interface AdminExerciseListItem {
  id: string
  chapter_id: string
  title: string
  type: ExerciseType
  difficulty: CourseDifficulty
  status: ExerciseStatus
  sort_order: number
  created_at: string
  updated_at: string
}

export interface AdminExerciseDetail extends AdminExerciseListItem {
  content_json: Record<string, unknown>
  solution_json?: Record<string, unknown> | null
}

// Challenge Types
export type ChallengeStatus = 'draft' | 'published' | 'archived'

export interface AdminChallengeListItem {
  id: string
  title: string
  description?: string
  difficulty: CourseDifficulty
  reward_xp: number
  status: ChallengeStatus
  related_course_id?: string | null
  created_at: string
  updated_at: string
}

export interface AdminChallengeDetail extends AdminChallengeListItem {
  content_json: Record<string, unknown>
}

// User Types
export type AccountStatus = 'active' | 'suspended' | 'closed'
export type AdminStatus = 'active' | 'disabled'
export type UserRole = 'learner' | 'admin'

export interface ProfileSummary {
  display_name: string
  avatar_url?: string | null
}

export interface AdminUserListItem {
  account_id: string
  email: string
  default_role: UserRole
  account_status: AccountStatus
  roles: UserRole[]
  profile_summary: ProfileSummary
  admin_status?: AdminStatus | null
  last_login_at?: string | null
  created_at: string
}

export interface Account {
  id: string
  email: string
  default_role: UserRole
  account_status: AccountStatus
  created_at: string
  updated_at: string
}

export interface AccountRole {
  role: UserRole
  granted_at: string
  granted_by?: string | null
}

export interface LearnerProfile {
  account_id: string
  nickname: string
  avatar_url?: string | null
  bio?: string | null
  xp: number
  streak_days: number
  created_at: string
  updated_at: string
}

export interface AdminProfile {
  account_id: string
  display_name: string
  department?: string | null
  created_at: string
  updated_at: string
}

export interface AdminUserDetail {
  account: Account
  roles: AccountRole[]
  learner_profile?: LearnerProfile | null
  admin_profile?: AdminProfile | null
}

export interface UpdateUserStatusInput {
  account_status: AccountStatus
  admin_status?: AdminStatus | null
  reason?: string | null
}

// Feedback Types
export type FeedbackCategory = 'content' | 'problem' | 'bug' | 'account' | 'other'
export type FeedbackStatus = 'open' | 'in_progress' | 'resolved' | 'closed'

export interface FeedbackTicket {
  id: string
  learner_id: string
  category: FeedbackCategory
  content: string
  screenshot_urls?: string[]
  status: FeedbackStatus
  admin_reply?: string | null
  replied_at?: string | null
  created_at: string
}

export interface AdminFeedbackListItem extends FeedbackTicket {
  learner_profile: {
    account_id: string
    nickname: string
    avatar_url?: string | null
  }
}

// Moderation Types
export type ModerationCaseType = 'nickname' | 'avatar' | 'feedback'
export type ModerationStatus = 'pending' | 'approved' | 'rejected'

export interface ModerationCase {
  id: string
  case_type: ModerationCaseType
  target_id: string
  target_snapshot_json: Record<string, unknown>
  status: ModerationStatus
  decision_reason?: string | null
  reviewed_by?: string | null
  reviewed_at?: string | null
  created_at: string
}

export interface AdminModerationListItem extends ModerationCase {
  target_summary?: {
    target_label: string
    target_owner_id?: string | null
  }
  reviewer_profile?: {
    account_id: string
    display_name: string
    avatar_url?: string | null
  } | null
}

export interface UpdateModerationInput {
  status: ModerationStatus
  decision_reason?: string | null
}

// Announcement Types
export type AnnouncementAudience = 'all_learners' | 'all_admins' | 'all'
export type AnnouncementStatus = 'draft' | 'published' | 'expired'

export interface Announcement {
  id: string
  title: string
  body_markdown: string
  audience: AnnouncementAudience
  status: AnnouncementStatus
  published_at?: string | null
  expires_at?: string | null
  created_by: string
  created_at: string
  updated_at: string
}

export interface AdminAnnouncementCreateInput {
  title: string
  body_markdown: string
  audience: AnnouncementAudience
  status: AnnouncementStatus
  published_at?: string | null
  expires_at?: string | null
}

// System Config Types
export type ConfigScope = 'system' | 'ai' | 'challenge' | 'reward'
export type ConfigStatus = 'active' | 'inactive'

export interface SystemConfig {
  id: string
  config_key: string
  config_scope: ConfigScope
  value_json: Record<string, unknown>
  status: ConfigStatus
  updated_by: string
  updated_at: string
}

export interface AdminSystemConfigUpdateInput {
  config_scope: ConfigScope
  value_json: Record<string, unknown>
  status: ConfigStatus
}

// Dashboard Stats Types
export interface DashboardStats {
  total_users: number
  total_courses: number
  total_submissions: number
  active_today: number
  pending_moderation: number
  trend: {
    dates: string[]
    new_users: number[]
    submissions: number[]
    active_users: number[]
  }
}

export interface Activity {
  id: string
  user_id: string
  user_name: string
  action: string
  target_type: string
  target_name: string
  created_at: string
}

// Auth Types
export interface LoginRequest {
  email: string
  password: string
}

export interface LoginResponse {
  account_id: string
  active_role: UserRole
  access_token: string
  refresh_token: string
  expires_in: number
  session_id: string
  token_type: string
  profile: Record<string, unknown>
}

// List query parameters
export interface ListQueryParams {
  page?: number
  page_size?: number
  sort_by?: string
  sort_order?: 'asc' | 'desc'
  search?: string
  status?: string
}
