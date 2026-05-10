import type { AxiosResponse } from 'axios'

// Override axios response type to account for our interceptor
// that returns response.data directly
declare module 'axios' {
  export interface AxiosInstance {
    get<T = unknown, R = T, D = unknown>(url: string, config?: AxiosRequestConfig<D>): Promise<R>
    post<T = unknown, R = T, D = unknown>(url: string, data?: D, config?: AxiosRequestConfig<D>): Promise<R>
    patch<T = unknown, R = T, D = unknown>(url: string, data?: D, config?: AxiosRequestConfig<D>): Promise<R>
    delete<T = unknown, R = T, D = unknown>(url: string, config?: AxiosRequestConfig<D>): Promise<R>
  }
}
