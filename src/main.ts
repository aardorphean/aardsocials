import { createApp } from 'vue'

import Oruga from '@oruga-ui/oruga-next'
import { bulmaConfig } from '@oruga-ui/theme-bulma'

import VueApexCharts from 'vue3-apexcharts'

import '@oruga-ui/theme-bulma/dist/bulma.css'
import '@mdi/font/css/materialdesignicons.min.css'

import App from './App.vue'

createApp(App).use(Oruga, bulmaConfig).use(VueApexCharts).mount('#app')
