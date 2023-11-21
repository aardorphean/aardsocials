<script setup lang="ts">
import { ref, type Ref, onMounted } from 'vue'
import Fuse from 'fuse.js'
import socialData from '@/assets/aard_socials.json'

interface Social {
  name: string
  playerUsage: number
  mobUsage: number
  youNoArg: string
  othersNoArg: string
  youArg: string
  othersArg: string
  target: string
  youSelf: string
  othersSelf: string
}

interface GraphData {
  x: string
  y: number
}

let index: Fuse<Social> | null = null

let searchTerm = ref('')
let searchResults: Ref<Fuse.FuseResult<Social>[]> = ref([])
let loading = ref(false)
let indexLoading = ref(true)

let creatorData: Ref<GraphData[]> = ref([])
let topCreatorData: Ref<GraphData[]> = ref([])
let playerUsageData: Ref<GraphData[]> = ref([])
let creatorOptions: Ref<any> | null = null
let creatorSeries: Ref<any[]> | null = null
let playerUsageOptions: Ref<any> | null = null
let playerUsageSeries: Ref<any[]> | null = null

let mobUsageData: Ref<GraphData[]> = ref([])
let mobUsageOptions: Ref<any> | null = null
let mobUsageSeries: Ref<any[]> | null = null

onMounted(() => {
  setTimeout(() => {
    const socialIndex = Fuse.createIndex(
      [
        'name',
        'creator',
        'youNoArg',
        'othersNoArg',
        'youArg',
        'othersArg',
        'target',
        'youSelf',
        'othersSelf'
      ],
      socialData
    )

    index = new Fuse(
      socialData,
      {
        keys: [
          'name',
          'creator',
          'youNoArg',
          'othersNoArg',
          'youArg',
          'othersArg',
          'target',
          'youSelf',
          'othersSelf'
        ],
        includeScore: true
      },
      socialIndex
    )
    indexLoading.value = false
  }, 2000)

  let i = 0
  const length = socialData.length
  const creators: { [key: string]: GraphData } = {}

  while (i < length) {
    const creator = socialData[i].creator

    if (typeof creators[creator] === 'undefined') {
      creators[creator] = {
        x: creator,
        y: 0
      }
    }

    creators[creator].y++
    i++
  }

  for (const key of Object.keys(creators)) {
    const v = creators[key]
    creatorData.value.push(v)
  }

  creatorData.value.sort((a, b) => {
    return b.y - a.y
  })

  socialData.sort((a, b) => {
    return b.playerUsage - a.playerUsage
  })

  for (i = 1; i < 11; i++) {
    topCreatorData.value.push(creatorData.value[i])
  }

  for (i = 0; i < 10; i++) {
    const social = socialData[i]
    playerUsageData.value.push({
      x: social.name,
      y: social.playerUsage
    })
  }

  socialData.sort((a, b) => {
    return b.mobUsage - a.mobUsage
  })

  for (i = 0; i < 10; i++) {
    const social = socialData[i]
    mobUsageData.value.push({
      x: social.name,
      y: social.mobUsage
    })
  }

  creatorOptions = ref({
    plotOptions: {
      bar: {
        horizontal: true,
        borderRadius: 4
      }
    },
    dataLabels: {
      enabled: false
    },
    xaxis: {
      categories: topCreatorData.value.map(i => i.x)
    },
    title: {
      text: 'Top 10 Social Creators'
    }
  })

  creatorSeries = ref([
    {
      name: 'Top Creator',
      data: topCreatorData.value.map(i => i.y)
    }
  ])

  playerUsageOptions = ref({
    plotOptions: {
      bar: {
        horizontal: true,
        borderRadius: 4
      }
    },
    dataLabels: {
      enabled: false
    },
    xaxis: {
      categories: playerUsageData.value.map(i => i.x)
    },
    title: {
      text: 'Top 10 Socials by Player Usage'
    }
  })

  playerUsageSeries = ref([
    {
      name: 'Player Usage',
      data: playerUsageData.value.map(i => i.y)
    }
  ])

  mobUsageOptions = ref({
    plotOptions: {
      bar: {
        horizontal: true,
        borderRadius: 4
      }
    },
    dataLabels: {
      enabled: false
    },
    xaxis: {
      categories: mobUsageData.value.map(i => i.x)
    },
    title: {
      text: 'Top 10 Socials by Mob Usage'
    }
  })

  mobUsageSeries = ref([
    {
      name: 'Mob Usage',
      data: mobUsageData.value.map(i => i.y)
    }
  ])
})

function clearSearch() {
  searchResults.value = []
  searchTerm = ref('')
}

async function searchSocials() {
  searchResults.value = []

  if (searchTerm.value.length === 0) {
    return
  }

  if (!index) {
    return
  }

  loading.value = true
  await executeSearch(index, searchTerm.value)
  loading.value = false
}

async function executeSearch(index: Fuse<Social>, term: string): Promise<void> {
  return new Promise(resolve => {
    searchResults.value = index.search(term)
    resolve()
  })
}
</script>

<template>
  <div id="app">
    <nav class="navbar" role="navigation" aria-label="main navigation">
      <div class="navbar-brand">
        <a class="navbar-item title" href="https://aard.social">AardSocials</a>
      </div>

      <div class="navbar-menu">
        <div class="navbar-end">
          <div class="navbar-item">
            <p class="subtitle">Data Last Refreshed: 18 July 2023</p>
          </div>
        </div>
      </div>
    </nav>

    <section class="section">
      <div class="container">
        <o-tabs>
          <o-tab-item label="Search" icon="magnify">
            <div class="card">
              <div class="card-content">
                <form @submit.prevent="searchSocials">
                  <o-field>
                    <o-input
                      v-model="searchTerm"
                      expanded
                      placeholder="Search for keywords..."
                      icon="magnify"
                      icon-right="close-circle"
                      icon-right-clickable
                      @icon-right-click="clearSearch"
                      :disabled="loading"
                      :loading="loading"
                    />
                    <o-button
                      variant="success"
                      icon-left="magnify"
                      native-type="submit"
                      :disabled="loading"
                      :loading="loading"
                    >
                      Search
                    </o-button>
                  </o-field>
                </form>
              </div>
            </div>

            <div class="card">
              <div class="card-content">
                <o-table
                  v-if="searchResults.length > 0"
                  :data="searchResults"
                  paginated
                  :per-page="50"
                  hoverable
                  detailed
                  striped
                  mobile-cards
                  default-sort-direction="asc"
                  default-sort="score"
                  :loading="loading"
                >
                  <o-table-column
                    field="item.name"
                    label="Name"
                    sortable
                    searchable
                    #default="props"
                  >
                    {{ props.row.item.name }}
                  </o-table-column>
                  <o-table-column
                    field="item.creator"
                    label="Creator"
                    sortable
                    searchable
                    #default="props"
                  >
                    {{ props.row.item.creator }}
                  </o-table-column>
                  <o-table-column
                    field="item.playerUsage"
                    label="Player Usage"
                    sortable
                    searchable
                    numeric
                    #default="props"
                  >
                    {{ props.row.item.playerUsage }}
                  </o-table-column>
                  <o-table-column
                    field="item.mobUsage"
                    label="Mob Usage"
                    sortable
                    searchable
                    numeric
                    #default="props"
                  >
                    {{ props.row.item.mobUsage }}
                  </o-table-column>
                  <o-table-column
                    field="score"
                    label="Score"
                    sortable
                    numeric
                    #default="props"
                  >
                    {{ (1 - props.row.score).toFixed(2) }}
                  </o-table-column>

                  <template #detail="props">
                    <tr>
                      <td>1</td>
                      <td>You, No Target</td>
                      <td>{{ props.row.item.youNoArg }}</td>
                    </tr>
                    <tr>
                      <td>2</td>
                      <td>Other People, No Target</td>
                      <td>{{ props.row.item.othersNoArg }}</td>
                    </tr>
                    <tr>
                      <td>3</td>
                      <td>You, With Target</td>
                      <td>{{ props.row.item.youArg }}</td>
                    </tr>
                    <tr>
                      <td>4</td>
                      <td>Other People, With Target</td>
                      <td>{{ props.row.item.othersArg }}</td>
                    </tr>
                    <tr>
                      <td>5</td>
                      <td>Your Target</td>
                      <td>{{ props.row.item.target }}</td>
                    </tr>
                    <tr>
                      <td>6</td>
                      <td>You, With Self As Target</td>
                      <td>{{ props.row.item.youSelf }}</td>
                    </tr>
                    <tr>
                      <td>7</td>
                      <td>Other People, With Self As Target</td>
                      <td>{{ props.row.item.othersSelf }}</td>
                    </tr>
                  </template>
                </o-table>
                <o-table
                  v-show="searchResults.length === 0"
                  :data="socialData"
                  paginated
                  :per-page="50"
                  hoverable
                  detailed
                  striped
                  mobile-cards
                  default-sort-direction="desc"
                  default-sort="playerUsage"
                  :loading="loading"
                >
                  <o-table-column
                    field="name"
                    label="Name"
                    sortable
                    searchable
                    #default="props"
                  >
                    {{ props.row.name }}
                  </o-table-column>
                  <o-table-column
                    field="creator"
                    label="Creator"
                    sortable
                    searchable
                    #default="props"
                  >
                    {{ props.row.creator }}
                  </o-table-column>
                  <o-table-column
                    field="playerUsage"
                    label="Player Usage"
                    sortable
                    searchable
                    numeric
                    #default="props"
                  >
                    {{ props.row.playerUsage }}
                  </o-table-column>
                  <o-table-column
                    field="mobUsage"
                    label="Mob Usage"
                    sortable
                    searchable
                    numeric
                    #default="props"
                  >
                    {{ props.row.mobUsage }}
                  </o-table-column>

                  <template #detail="props">
                    <tr>
                      <td>1</td>
                      <td>You, No Target</td>
                      <td>{{ props.row.youNoArg }}</td>
                    </tr>
                    <tr>
                      <td>2</td>
                      <td>Other People, No Target</td>
                      <td>{{ props.row.othersNoArg }}</td>
                    </tr>
                    <tr>
                      <td>3</td>
                      <td>You, With Target</td>
                      <td>{{ props.row.youArg }}</td>
                    </tr>
                    <tr>
                      <td>4</td>
                      <td>Other People, With Target</td>
                      <td>{{ props.row.othersArg }}</td>
                    </tr>
                    <tr>
                      <td>5</td>
                      <td>Your Target</td>
                      <td>{{ props.row.target }}</td>
                    </tr>
                    <tr>
                      <td>6</td>
                      <td>You, With Self As Target</td>
                      <td>{{ props.row.youSelf }}</td>
                    </tr>
                    <tr>
                      <td>7</td>
                      <td>Other People, With Self As Target</td>
                      <td>{{ props.row.othersSelf }}</td>
                    </tr>
                  </template>
                </o-table>
              </div>
            </div>
          </o-tab-item>
          <o-tab-item label="Stats" icon="chart-line">
            <div class="columns">
              <div class="col">
                <apexchart
                  v-if="creatorSeries"
                  width="550"
                  type="bar"
                  :options="creatorOptions"
                  :series="creatorSeries"
                />
              </div>
              <div class="col">
                <apexchart
                  v-if="playerUsageSeries"
                  width="550"
                  type="bar"
                  :options="playerUsageOptions"
                  :series="playerUsageSeries"
                />
              </div>
            </div>
            <div class="columns">
              <div class="col">
                <apexchart
                  v-if="mobUsageSeries"
                  width="550"
                  type="bar"
                  :options="mobUsageOptions"
                  :series="mobUsageSeries"
                />
              </div>
              <div class="col">&nbsp;</div>
            </div>
          </o-tab-item>
        </o-tabs>
      </div>
    </section>

    <footer class="footer">
      <div class="content has-text-centered">
        <p>
          <strong>AardSocials</strong>
          by
          <span>
            Orphean @
            <a href="https://www.aardwolf.com/" target="_blank">Aardwolf</a>
          </span>
          Blame him for this travesty.
        </p>
      </div>
    </footer>

    <o-loading full-page v-model:active="indexLoading"></o-loading>
  </div>
</template>
