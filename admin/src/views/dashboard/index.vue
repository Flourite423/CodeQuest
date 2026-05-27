<script setup lang="ts">
import { ref, onMounted, nextTick, markRaw } from "vue";
import { useRouter } from "vue-router";
import {
  User,
  Reading,
  View,
  Warning,
  DocumentChecked,
} from "@element-plus/icons-vue";
import type { DashboardStats } from "@/types";
import { statsApi } from "@/api";
import * as echarts from "echarts";

const router = useRouter();
const loading = ref(false);
const error = ref("");
const forbidden = ref(false);
const sessionExpired = ref(false);

const stats = ref<{ title: string; value: string; icon: any; color: string }[]>(
  [],
);
const trendChartRef = ref<HTMLDivElement | null>(null);
const barChartRef = ref<HTMLDivElement | null>(null);

let trendChart: echarts.ECharts | null = null;
let barChart: echarts.ECharts | null = null;

const initTrendChart = (data: DashboardStats) => {
  if (!trendChartRef.value) return;
  // 延迟初始化确保容器有正确尺寸
  setTimeout(() => {
    if (!trendChartRef.value) return;
    try {
      trendChart = echarts.init(trendChartRef.value);
      trendChart.setOption({
        title: {
          text: "近7天活跃用户趋势",
          left: "center",
          textStyle: { fontSize: 16 },
        },
        tooltip: { trigger: "axis" },
        grid: { left: "3%", right: "4%", bottom: "3%", containLabel: true },
        xAxis: {
          type: "category",
          boundaryGap: false,
          data: data.trend.dates,
          axisLine: { lineStyle: { color: "#909399" } },
        },
        yAxis: {
          type: "value",
          axisLine: { lineStyle: { color: "#909399" } },
          splitLine: { lineStyle: { color: "#EBEEF5" } },
        },
        series: [
          {
            name: "活跃用户数",
            type: "line",
            smooth: true,
            data: data.trend.active_users,
            areaStyle: {
              color: new (echarts as any).graphic.LinearGradient(0, 0, 0, 1, [
                { offset: 0, color: "rgba(64,158,255,0.3)" },
                { offset: 1, color: "rgba(64,158,255,0.05)" },
              ]),
            },
            lineStyle: { color: "#409EFF", width: 3 },
            itemStyle: { color: "#409EFF" },
            symbol: "circle",
            symbolSize: 8,
          },
        ],
      });
    } catch (e) {
      console.error("Trend chart init failed:", e);
    }
  }, 100);
};

const initBarChart = (data: DashboardStats) => {
  if (!barChartRef.value) return;
  setTimeout(() => {
    if (!barChartRef.value) return;
    try {
      barChart = echarts.init(barChartRef.value);
      barChart.setOption({
        title: {
          text: "近7天数据增长",
          left: "center",
          textStyle: { fontSize: 16 },
        },
        tooltip: { trigger: "axis", axisPointer: { type: "shadow" } },
        legend: { data: ["新增用户", "提交数量"], bottom: 0 },
        grid: { left: "3%", right: "4%", bottom: "10%", containLabel: true },
        xAxis: {
          type: "category",
          data: data.trend.dates,
          axisLine: { lineStyle: { color: "#909399" } },
        },
        yAxis: {
          type: "value",
          axisLine: { lineStyle: { color: "#909399" } },
          splitLine: { lineStyle: { color: "#EBEEF5" } },
        },
        series: [
          {
            name: "新增用户",
            type: "bar",
            data: data.trend.new_users,
            itemStyle: { color: "#67C23A", borderRadius: [4, 4, 0, 0] },
            barWidth: "30%",
          },
          {
            name: "提交数量",
            type: "bar",
            data: data.trend.submissions,
            itemStyle: { color: "#E6A23C", borderRadius: [4, 4, 0, 0] },
            barWidth: "30%",
          },
        ],
      });
    } catch (e) {
      console.error("Bar chart init failed:", e);
    }
  }, 100);
};

const handleResize = () => {
  trendChart?.resize();
  barChart?.resize();
};

const fetchData = async () => {
  loading.value = true;
  error.value = "";
  forbidden.value = false;
  sessionExpired.value = false;
  try {
    const statsRes = await statsApi.dashboard();
    const data = statsRes.data as DashboardStats;

    stats.value = [
      {
        title: "总用户数",
        value: data.total_users.toLocaleString(),
        icon: markRaw(User),
        color: "#409EFF",
      },
      {
        title: "总课程数",
        value: data.total_courses.toLocaleString(),
        icon: markRaw(Reading),
        color: "#67C23A",
      },
      {
        title: "总提交数",
        value: data.total_submissions.toLocaleString(),
        icon: markRaw(DocumentChecked),
        color: "#909399",
      },
      {
        title: "今日活跃",
        value: data.active_today.toLocaleString(),
        icon: markRaw(View),
        color: "#E6A23C",
      },
      {
        title: "待审核数",
        value: data.pending_moderation.toLocaleString(),
        icon: markRaw(Warning),
        color: "#F56C6C",
      },
    ];

    await nextTick();
    initTrendChart(data);
    initBarChart(data);
  } catch (e: unknown) {
    if (e instanceof Error && e.message.includes("403")) {
      forbidden.value = true;
    } else if (e instanceof Error && e.message.includes("401")) {
      sessionExpired.value = true;
      setTimeout(() => router.push("/login?expired=1"), 2000);
    } else {
      error.value = "加载数据失败，请重试";
    }
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  fetchData();
  window.addEventListener("resize", handleResize);
});
</script>

<template>
  <div class="dashboard">
    <h1>数据看板</h1>

    <div v-if="loading" class="state-container">
      <el-skeleton :rows="3" animated />
    </div>

    <div v-else-if="forbidden" class="state-container">
      <el-icon class="state-icon" color="#F56C6C"><Warning /></el-icon>
      <p class="state-text">无权访问</p>
    </div>

    <div v-else-if="sessionExpired" class="state-container">
      <el-icon class="state-icon" color="#E6A23C"><Warning /></el-icon>
      <p class="state-text">登录已过期，请重新登录</p>
      <p class="state-subtext">正在跳转到登录页...</p>
    </div>

    <div v-else-if="error" class="state-container">
      <el-icon class="state-icon" color="#F56C6C"><Warning /></el-icon>
      <p class="state-text">{{ error }}</p>
      <el-button type="primary" @click="fetchData">重试</el-button>
    </div>

    <template v-else>
      <!-- 统计卡片 -->
      <el-row :gutter="16" class="stats-row">
        <el-col
          v-for="stat in stats"
          :key="stat.title"
          :xs="12"
          :sm="8"
          :md="4"
          :lg="4"
        >
          <el-card class="stat-card" shadow="hover">
            <div class="stat-content">
              <el-icon :size="36" :color="stat.color">
                <component :is="stat.icon" />
              </el-icon>
              <div class="stat-info">
                <p class="stat-value">{{ stat.value }}</p>
                <p class="stat-title">{{ stat.title }}</p>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <!-- ECharts 图表 -->
      <el-row :gutter="16" class="chart-row">
        <el-col :xs="24" :lg="12">
          <el-card class="chart-card" shadow="hover">
            <div ref="trendChartRef" class="chart-container" />
          </el-card>
        </el-col>
        <el-col :xs="24" :lg="12">
          <el-card class="chart-card" shadow="hover">
            <div ref="barChartRef" class="chart-container" />
          </el-card>
        </el-col>
      </el-row>
    </template>
  </div>
</template>

<style scoped lang="scss">
.dashboard {
  h1 {
    margin-bottom: 20px;
    color: #303133;
    font-size: 22px;
    font-weight: 600;
  }
}

.stats-row {
  margin-bottom: 16px;
}

.stat-card {
  margin-bottom: 16px;
  :deep(.el-card__body) {
    padding: 16px;
  }
  .stat-content {
    display: flex;
    align-items: center;
    gap: 12px;
  }
  .stat-info {
    .stat-value {
      font-size: 22px;
      font-weight: bold;
      color: #303133;
      margin: 0;
      line-height: 1.2;
    }
    .stat-title {
      font-size: 13px;
      color: #909399;
      margin: 4px 0 0;
    }
  }
}

.chart-row {
  .chart-card {
    margin-bottom: 16px;
    :deep(.el-card__body) {
      padding: 12px;
    }
  }
  .chart-container {
    width: 100%;
    height: 320px;
  }
}

.state-container {
  text-align: center;
  padding: 60px 20px;
  .state-icon {
    font-size: 48px;
    margin-bottom: 12px;
  }
  .state-text {
    font-size: 16px;
    color: #606266;
    margin: 0 0 8px;
  }
  .state-subtext {
    font-size: 14px;
    color: #909399;
    margin: 0;
  }
}
</style>
