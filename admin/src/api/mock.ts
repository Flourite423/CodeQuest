import type {
  Activity,
  AdminChallengeDetail,
  AdminChallengeListItem,
  AdminCourseDetail,
  AdminCourseListItem,
  AdminExerciseDetail,
  AdminExerciseListItem,
  AdminFeedbackListItem,
  AdminModerationListItem,
  AdminUserDetail,
  AdminUserListItem,
  Announcement,
  DashboardStats,
  LoginResponse,
  PaginatedResponse,
  SuccessEnvelope,
  SystemConfig,
} from '@/types'

type RequestLike = {
  url?: string
  method?: string
  params?: Record<string, unknown>
  data?: unknown
}

type MockUserSeed = {
  id: string
  displayName: string
  profileNickname: string
  email: string
  role: 'admin' | 'learner'
  level: number
  xp: number
  streakDays: number
  accountStatus: 'active' | 'suspended' | 'closed'
  createdAt: string
  updatedAt: string
  lastLoginAt: string | null
}

const MOCK_ADMIN_TOKEN = 'mock-admin-jwt-token-001'
const MOCK_REFRESH_TOKEN = 'mock-admin-refresh-token-001'
const MOCK_SESSION_ID = 'mock-admin-session-001'

const now = new Date()

const isoAgo = (durationMs: number) => new Date(now.getTime() - durationMs).toISOString()

const dateOnlyAgo = (daysAgo: number) => {
  const date = new Date(now)
  date.setDate(date.getDate() - daysAgo)
  return date.toISOString().slice(0, 10)
}

const success = <T>(data: T): SuccessEnvelope<T> => ({
  code: 'ok',
  message: 'success',
  data,
})

const emptySuccess = () => success<Record<string, never>>({})

const parseNumber = (value: unknown, fallback: number) => {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return value
  }
  if (typeof value === 'string') {
    const parsed = Number(value)
    if (Number.isFinite(parsed)) {
      return parsed
    }
  }
  return fallback
}

const paginate = <T>(items: T[], params?: Record<string, unknown>): PaginatedResponse<T> => {
  const page = Math.max(1, parseNumber(params?.page, 1))
  const pageSize = Math.max(1, parseNumber(params?.page_size, 10))
  const start = (page - 1) * pageSize
  const pagedItems = items.slice(start, start + pageSize)

  return {
    items: pagedItems,
    meta: {
      page,
      page_size: pageSize,
      total: items.length,
      has_more: start + pageSize < items.length,
    },
  }
}

const normalizePath = (url?: string) => {
  if (!url) {
    return ''
  }

  const trimmed = url.replace(/^https?:\/\/[^/]+/i, '')
  const [pathOnly] = trimmed.split('?')
  return pathOnly.replace(/^\/api\/v1/, '') || '/'
}

const parseBody = (data: unknown): Record<string, unknown> => {
  if (!data) {
    return {}
  }
  if (typeof data === 'string') {
    try {
      return JSON.parse(data) as Record<string, unknown>
    } catch {
      return {}
    }
  }
  if (typeof data === 'object') {
    return data as Record<string, unknown>
  }
  return {}
}

const mockUserSeeds: MockUserSeed[] = [
  {
    id: 'mock-user-001',
    displayName: '张同学',
    profileNickname: '张同学',
    email: 'admin@example.com',
    role: 'admin',
    level: 8,
    xp: 2850,
    streakDays: 7,
    accountStatus: 'active',
    createdAt: '2026-05-01T09:00:00.000Z',
    updatedAt: '2026-05-29T09:00:00.000Z',
    lastLoginAt: now.toISOString(),
  },
  {
    id: 'mock-user-002',
    displayName: '李同学',
    profileNickname: '李同学',
    email: 'li@example.com',
    role: 'learner',
    level: 5,
    xp: 1800,
    streakDays: 4,
    accountStatus: 'active',
    createdAt: '2026-05-02T09:00:00.000Z',
    updatedAt: '2026-05-29T09:00:00.000Z',
    lastLoginAt: isoAgo(18 * 60 * 1000),
  },
  {
    id: 'mock-user-003',
    displayName: '王同学',
    profileNickname: '王同学',
    email: 'wang@example.com',
    role: 'learner',
    level: 8,
    xp: 2700,
    streakDays: 6,
    accountStatus: 'active',
    createdAt: '2026-05-03T09:00:00.000Z',
    updatedAt: '2026-05-29T09:00:00.000Z',
    lastLoginAt: isoAgo(2 * 60 * 60 * 1000),
  },
  {
    id: 'mock-user-004',
    displayName: '赵同学',
    profileNickname: '赵同学',
    email: 'zhao@example.com',
    role: 'learner',
    level: 3,
    xp: 800,
    streakDays: 2,
    accountStatus: 'active',
    createdAt: '2026-05-04T09:00:00.000Z',
    updatedAt: '2026-05-29T09:00:00.000Z',
    lastLoginAt: isoAgo(3 * 24 * 60 * 60 * 1000),
  },
  {
    id: 'mock-user-005',
    displayName: '学霸张',
    profileNickname: '学霸张',
    email: 'chen@example.com',
    role: 'learner',
    level: 12,
    xp: 5200,
    streakDays: 15,
    accountStatus: 'active',
    createdAt: '2026-05-05T09:00:00.000Z',
    updatedAt: '2026-05-29T09:00:00.000Z',
    lastLoginAt: isoAgo(5 * 60 * 60 * 1000),
  },
  {
    id: 'mock-user-006',
    displayName: '代码侠',
    profileNickname: '代码侠',
    email: 'liu@example.com',
    role: 'learner',
    level: 10,
    xp: 4800,
    streakDays: 10,
    accountStatus: 'active',
    createdAt: '2026-05-06T09:00:00.000Z',
    updatedAt: '2026-05-29T09:00:00.000Z',
    lastLoginAt: isoAgo(2 * 24 * 60 * 60 * 1000),
  },
]

const mockCourses: AdminCourseDetail[] = [
  {
    id: 'mock-course-001',
    course_code: 'HTML101',
    title: 'HTML 基础入门',
    summary: '学习 HTML 的基础知识，包括标签、属性和页面结构',
    description: '学习 HTML 的基础知识，包括标签、属性和页面结构',
    difficulty: 'beginner',
    estimated_minutes: 120,
    status: 'published',
    sort_order: 1,
    content_version: 1,
    created_by: 'mock-user-001',
    published_at: '2026-05-10T09:00:00.000Z',
    created_at: '2026-05-08T09:00:00.000Z',
    updated_at: '2026-05-29T09:00:00.000Z',
    cover_image_url: null,
    chapters: [
      {
        id: 'mock-chapter-001',
        course_id: 'mock-course-001',
        title: 'HTML 简介',
        sort_order: 1,
        status: 'published',
        created_at: '2026-05-08T09:00:00.000Z',
        updated_at: '2026-05-29T09:00:00.000Z',
      },
      {
        id: 'mock-chapter-002',
        course_id: 'mock-course-001',
        title: 'HTML 标签',
        sort_order: 2,
        status: 'published',
        created_at: '2026-05-08T09:00:00.000Z',
        updated_at: '2026-05-29T09:00:00.000Z',
      },
      {
        id: 'mock-chapter-003',
        course_id: 'mock-course-001',
        title: 'HTML 属性',
        sort_order: 3,
        status: 'published',
        created_at: '2026-05-08T09:00:00.000Z',
        updated_at: '2026-05-29T09:00:00.000Z',
      },
    ],
  },
  {
    id: 'mock-course-002',
    course_code: 'CSS101',
    title: 'CSS 基础入门',
    summary: '学习 CSS 的基础知识，包括选择器、属性和布局',
    description: '学习 CSS 的基础知识，包括选择器、属性和布局',
    difficulty: 'beginner',
    estimated_minutes: 150,
    status: 'published',
    sort_order: 2,
    content_version: 1,
    created_by: 'mock-user-001',
    published_at: '2026-05-11T09:00:00.000Z',
    created_at: '2026-05-09T09:00:00.000Z',
    updated_at: '2026-05-29T09:00:00.000Z',
    cover_image_url: null,
    chapters: [
      {
        id: 'mock-chapter-004',
        course_id: 'mock-course-002',
        title: 'CSS 简介',
        sort_order: 1,
        status: 'published',
        created_at: '2026-05-09T09:00:00.000Z',
        updated_at: '2026-05-29T09:00:00.000Z',
      },
      {
        id: 'mock-chapter-005',
        course_id: 'mock-course-002',
        title: 'CSS 选择器',
        sort_order: 2,
        status: 'published',
        created_at: '2026-05-09T09:00:00.000Z',
        updated_at: '2026-05-29T09:00:00.000Z',
      },
    ],
  },
  {
    id: 'mock-course-003',
    course_code: 'JS101',
    title: 'JavaScript 基础入门',
    summary: '学习 JavaScript 的基础知识，包括变量、函数和控制流',
    description: '学习 JavaScript 的基础知识，包括变量、函数和控制流',
    difficulty: 'beginner',
    estimated_minutes: 180,
    status: 'published',
    sort_order: 3,
    content_version: 1,
    created_by: 'mock-user-001',
    published_at: '2026-05-12T09:00:00.000Z',
    created_at: '2026-05-10T09:00:00.000Z',
    updated_at: '2026-05-29T09:00:00.000Z',
    cover_image_url: null,
    chapters: [
      {
        id: 'mock-chapter-007',
        course_id: 'mock-course-003',
        title: 'JavaScript 简介',
        sort_order: 1,
        status: 'published',
        created_at: '2026-05-10T09:00:00.000Z',
        updated_at: '2026-05-29T09:00:00.000Z',
      },
    ],
  },
  {
    id: 'mock-course-004',
    course_code: 'RWD201',
    title: '响应式设计',
    summary: '学习响应式设计的原理和实践',
    description: '学习响应式设计的原理和实践',
    difficulty: 'intermediate',
    estimated_minutes: 120,
    status: 'published',
    sort_order: 4,
    content_version: 1,
    created_by: 'mock-user-001',
    published_at: '2026-05-13T09:00:00.000Z',
    created_at: '2026-05-11T09:00:00.000Z',
    updated_at: '2026-05-29T09:00:00.000Z',
    cover_image_url: null,
    chapters: [
      {
        id: 'mock-chapter-010',
        course_id: 'mock-course-004',
        title: '响应式设计简介',
        sort_order: 1,
        status: 'published',
        created_at: '2026-05-11T09:00:00.000Z',
        updated_at: '2026-05-29T09:00:00.000Z',
      },
    ],
  },
]

const mockExercises: AdminExerciseDetail[] = [
  {
    id: 'mock-exercise-001',
    chapter_id: 'mock-chapter-005',
    title: 'CSS 类选择器练习',
    exercise_type: 'coding',
    difficulty: 'beginner',
    status: 'published',
    sort_order: 1,
    created_at: '2026-05-12T10:00:00.000Z',
    updated_at: '2026-05-29T09:00:00.000Z',
    content_json: {
      prompt: '请使用 CSS 类选择器将 class 为 highlight 的元素背景色设置为黄色。',
      starter_code: '.highlight {\n  /* 请在此编写你的 CSS 代码 */\n}',
    },
    solution_json: {
      selector: '.highlight',
      property: 'background-color',
      value: 'yellow',
    },
  },
  {
    id: 'mock-exercise-002',
    chapter_id: 'mock-chapter-001',
    title: 'HTML 基础概念',
    exercise_type: 'single_choice',
    difficulty: 'beginner',
    status: 'published',
    sort_order: 2,
    created_at: '2026-05-12T11:00:00.000Z',
    updated_at: '2026-05-29T09:00:00.000Z',
    content_json: {
      prompt: '以下哪个标签用于定义 HTML 文档的根元素？',
      options: ['<html>', '<body>', '<head>', '<div>'],
    },
    solution_json: {
      answer: 'A',
    },
  },
]

const mockChallenges: AdminChallengeDetail[] = [
  {
    id: 'mock-challenge-001',
    title: 'HTML 新手挑战',
    description: '测试你的 HTML 基础知识',
    difficulty: 'beginner',
    reward_xp: 50,
    status: 'published',
    related_course_id: 'mock-course-001',
    created_at: '2026-05-14T09:00:00.000Z',
    updated_at: '2026-05-29T09:00:00.000Z',
    content_json: { stars: 3 },
  },
  {
    id: 'mock-challenge-002',
    title: 'HTML 进阶挑战',
    description: '挑战更复杂的 HTML 结构',
    difficulty: 'beginner',
    reward_xp: 100,
    status: 'published',
    related_course_id: 'mock-course-001',
    created_at: '2026-05-15T09:00:00.000Z',
    updated_at: '2026-05-29T09:00:00.000Z',
    content_json: { stars: 2 },
  },
  {
    id: 'mock-challenge-003',
    title: 'CSS 基础挑战',
    description: '测试你的 CSS 基础知识',
    difficulty: 'beginner',
    reward_xp: 75,
    status: 'published',
    related_course_id: 'mock-course-002',
    created_at: '2026-05-16T09:00:00.000Z',
    updated_at: '2026-05-29T09:00:00.000Z',
    content_json: { stars: 0 },
  },
  {
    id: 'mock-challenge-004',
    title: 'CSS 布局挑战',
    description: '挑战 CSS 布局技术',
    difficulty: 'intermediate',
    reward_xp: 120,
    status: 'published',
    related_course_id: 'mock-course-002',
    created_at: '2026-05-17T09:00:00.000Z',
    updated_at: '2026-05-29T09:00:00.000Z',
    content_json: { stars: 0 },
  },
  {
    id: 'mock-challenge-005',
    title: 'JavaScript 基础挑战',
    description: '测试你的 JavaScript 基础知识',
    difficulty: 'beginner',
    reward_xp: 150,
    status: 'published',
    related_course_id: 'mock-course-003',
    created_at: '2026-05-18T09:00:00.000Z',
    updated_at: '2026-05-29T09:00:00.000Z',
    content_json: { stars: 0 },
  },
]

const mockActivities: Activity[] = [
  {
    id: 'mock-activity-001',
    user_id: 'mock-user-002',
    user_name: '李同学',
    action: 'completed',
    target_type: 'course',
    target_name: 'Dart 基础语法',
    created_at: isoAgo(18 * 60 * 1000),
  },
  {
    id: 'mock-activity-002',
    user_id: 'mock-user-003',
    user_name: '王同学',
    action: 'completed',
    target_type: 'challenge',
    target_name: 'CSS 布局挑战',
    created_at: isoAgo(2 * 60 * 60 * 1000),
  },
  {
    id: 'mock-activity-003',
    user_id: 'mock-user-005',
    user_name: '学霸张',
    action: 'earned',
    target_type: 'badge',
    target_name: '连续学习之星',
    created_at: isoAgo(5 * 60 * 60 * 1000),
  },
  {
    id: 'mock-activity-004',
    user_id: 'mock-user-001',
    user_name: '张同学',
    action: 'reached',
    target_type: 'streak',
    target_name: '7 天连续学习',
    created_at: isoAgo(24 * 60 * 60 * 1000),
  },
  {
    id: 'mock-activity-005',
    user_id: 'mock-user-006',
    user_name: '代码侠',
    action: 'completed',
    target_type: 'course',
    target_name: 'Flutter 布局实战',
    created_at: isoAgo(2 * 24 * 60 * 60 * 1000),
  },
]

const mockDashboardStats: DashboardStats = {
  total_users: 6,
  total_courses: 4,
  total_submissions: 156,
  active_today: 3,
  pending_moderation: 0,
  trend: {
    dates: [6, 5, 4, 3, 2, 1, 0].map((days) => dateOnlyAgo(days)),
    new_users: [1, 0, 2, 1, 0, 1, 0],
    submissions: [5, 8, 12, 7, 9, 6, 10],
    active_users: [2, 3, 4, 2, 3, 4, 3],
  },
}

const mockConfigs: SystemConfig[] = []
const mockFeedback: AdminFeedbackListItem[] = []
const mockModeration: AdminModerationListItem[] = []
const mockAnnouncements: Announcement[] = []

const adminUserList: AdminUserListItem[] = mockUserSeeds.map((user) => ({
  account_id: user.id,
  email: user.email,
  default_role: user.role,
  account_status: user.accountStatus,
  roles: [user.role],
  profile_summary: {
    display_name: user.displayName,
    avatar_url: null,
  },
  admin_status: user.role === 'admin' ? 'active' : null,
  last_login_at: user.lastLoginAt,
  created_at: user.createdAt,
}))

const adminUserDetails: AdminUserDetail[] = mockUserSeeds.map((user) => ({
  account: {
    id: user.id,
    email: user.email,
    default_role: user.role,
    account_status: user.accountStatus,
    created_at: user.createdAt,
    updated_at: user.updatedAt,
  },
  roles: [
    {
      role: user.role,
      granted_at: user.createdAt,
      granted_by: 'mock-user-001',
    },
  ],
  learner_profile: user.role === 'learner'
    ? {
        account_id: user.id,
        nickname: user.profileNickname,
        avatar_url: null,
        bio: null,
        xp: user.xp,
        streak_days: user.streakDays,
        created_at: user.createdAt,
        updated_at: user.updatedAt,
      }
    : null,
  admin_profile: user.role === 'admin'
    ? {
        account_id: user.id,
        display_name: user.displayName,
        department: '教务管理',
        created_at: user.createdAt,
        updated_at: user.updatedAt,
      }
    : null,
}))

const filterCourses = (params?: Record<string, unknown>) => {
  const search = String(params?.search ?? '').trim().toLowerCase()
  if (!search) {
    return mockCourses
  }

  return mockCourses.filter((course) =>
    [course.course_code, course.title, course.summary ?? '']
      .join(' ')
      .toLowerCase()
      .includes(search)
  )
}

const filterExercises = (params?: Record<string, unknown>) => {
  const type = String(params?.type ?? '').trim()
  const difficulty = String(params?.difficulty ?? '').trim()

  return mockExercises.filter((exercise) => {
    if (type && exercise.exercise_type !== type) {
      return false
    }
    if (difficulty && exercise.difficulty !== difficulty) {
      return false
    }
    return true
  })
}

const filterChallenges = (params?: Record<string, unknown>) => {
  const status = String(params?.status ?? '').trim()
  if (!status) {
    return mockChallenges
  }
  return mockChallenges.filter((challenge) => challenge.status === status)
}

const filterUsers = (params?: Record<string, unknown>) => {
  const search = String(params?.search ?? '').trim().toLowerCase()
  const status = String(params?.status ?? '').trim()

  return adminUserList.filter((user) => {
    if (status && user.account_status !== status) {
      return false
    }

    if (!search) {
      return true
    }

    return [user.email, user.profile_summary.display_name, user.account_id]
      .join(' ')
      .toLowerCase()
      .includes(search)
  })
}

export const mockAuthAdminLogin = (): SuccessEnvelope<LoginResponse> =>
  success({
    account_id: 'mock-user-001',
    active_role: 'admin',
    access_token: MOCK_ADMIN_TOKEN,
    refresh_token: MOCK_REFRESH_TOKEN,
    expires_in: 7200,
    session_id: MOCK_SESSION_ID,
    token_type: 'Bearer',
    profile: {
      display_name: '张同学',
      email: 'admin@example.com',
      level: 8,
      xp: 2850,
    },
  })

export const mockAdminDashboardStats = (): SuccessEnvelope<DashboardStats> => success(mockDashboardStats)

export const mockAdminActivities = (): SuccessEnvelope<Activity[]> => success(mockActivities)

export const mockAdminCourses = (
  params?: Record<string, unknown>
): SuccessEnvelope<PaginatedResponse<AdminCourseListItem>> =>
  success(paginate<AdminCourseListItem>(filterCourses(params), params))

export const mockAdminExercises = (
  params?: Record<string, unknown>
): SuccessEnvelope<PaginatedResponse<AdminExerciseListItem>> =>
  success(paginate<AdminExerciseListItem>(filterExercises(params), params))

export const mockAdminChallenges = (
  params?: Record<string, unknown>
): SuccessEnvelope<PaginatedResponse<AdminChallengeListItem>> =>
  success(paginate<AdminChallengeListItem>(filterChallenges(params), params))

export const mockAdminUsers = (
  params?: Record<string, unknown>
): SuccessEnvelope<PaginatedResponse<AdminUserListItem>> =>
  success(paginate<AdminUserListItem>(filterUsers(params), params))

export const mockAdminUserDetail = (userId: string): SuccessEnvelope<AdminUserDetail | Record<string, never>> => {
  const user = adminUserDetails.find((item) => item.account.id === userId)
  return user ? success(user) : emptySuccess()
}

export const mockAdminConfigs = (
  params?: Record<string, unknown>
): SuccessEnvelope<PaginatedResponse<SystemConfig>> => success(paginate(mockConfigs, params))

export const mockAdminFeedback = (
  params?: Record<string, unknown>
): SuccessEnvelope<PaginatedResponse<AdminFeedbackListItem>> => success(paginate(mockFeedback, params))

export const mockAdminModeration = (
  params?: Record<string, unknown>
): SuccessEnvelope<PaginatedResponse<AdminModerationListItem>> => success(paginate(mockModeration, params))

export const mockAdminAnnouncements = (
  params?: Record<string, unknown>
): SuccessEnvelope<PaginatedResponse<Announcement>> => success(paginate(mockAnnouncements, params))

export const resolveMockApiResponse = (request: RequestLike) => {
  const method = String(request.method ?? 'get').toLowerCase()
  const path = normalizePath(request.url)
  const params = request.params
  const body = parseBody(request.data)

  if (method === 'post' && path === '/auth/admin/login') {
    return mockAuthAdminLogin()
  }

  if (method === 'get' && path === '/admin/stats/dashboard') {
    return mockAdminDashboardStats()
  }

  if (method === 'get' && path === '/admin/stats/activities') {
    return mockAdminActivities()
  }

  if (method === 'get' && path === '/admin/courses') {
    return mockAdminCourses(params)
  }

  if (method === 'get' && path === '/admin/exercises') {
    return mockAdminExercises(params)
  }

  if (method === 'get' && path === '/admin/challenges') {
    return mockAdminChallenges(params)
  }

  if (method === 'get' && path === '/admin/users') {
    return mockAdminUsers(params)
  }

  if (method === 'get' && path.startsWith('/admin/users/')) {
    return mockAdminUserDetail(path.split('/').pop() ?? '')
  }

  if (method === 'get' && path === '/admin/configs') {
    return mockAdminConfigs(params)
  }

  if (method === 'get' && path === '/admin/feedback') {
    return mockAdminFeedback(params)
  }

  if (method === 'get' && path === '/admin/moderation') {
    return mockAdminModeration(params)
  }

  if (method === 'get' && path === '/admin/announcements') {
    return mockAdminAnnouncements(params)
  }

  if (path.startsWith('/admin/') || path.startsWith('/auth/')) {
    if (method === 'patch' && path.startsWith('/admin/users/') && path.endsWith('/status')) {
      return mockAdminUserDetail(path.split('/')[3] ?? '')
    }

    if (method === 'post' && path === '/admin/courses') {
      return success({ ...mockCourses[0], ...body, id: `mock-course-created-${Date.now()}` })
    }

    if (method === 'patch' && path.startsWith('/admin/courses/')) {
      return success({ ...mockCourses[0], ...body, id: path.split('/').pop() ?? mockCourses[0].id })
    }

    if (method === 'post' && path === '/admin/exercises') {
      return success({ ...mockExercises[0], ...body, id: `mock-exercise-created-${Date.now()}` })
    }

    if (method === 'patch' && path.startsWith('/admin/exercises/')) {
      return success({ ...mockExercises[0], ...body, id: path.split('/').pop() ?? mockExercises[0].id })
    }

    if (method === 'post' && path === '/admin/challenges') {
      return success({ ...mockChallenges[0], ...body, id: `mock-challenge-created-${Date.now()}` })
    }

    if (method === 'patch' && path.startsWith('/admin/challenges/')) {
      return success({ ...mockChallenges[0], ...body, id: path.split('/').pop() ?? mockChallenges[0].id })
    }

    return emptySuccess()
  }

  return null
}
