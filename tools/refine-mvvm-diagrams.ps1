$ErrorActionPreference = 'Stop'

$Root = Resolve-Path (Join-Path $PSScriptRoot '..\learning-materials')
$PageEncoding = [Text.Encoding]::Default

function Card($code, $title, $detail) {
  return @"
    <div class="diagram-card">
      <strong>$code</strong>
      <h4>$title</h4>
      <p>$detail</p>
    </div>
"@
}

function Build-Grid($title, $cols, $items) {
  $cards = ($items | ForEach-Object { Card $_.code $_.title $_.detail }) -join "`n"
  return @"
<div class="visual">
  <div class="visual-title">$title</div>
  <div class="edu-diagram">
    <div class="diagram-grid $cols">
$cards
    </div>
  </div>
</div>
"@
}

function Step($num, $title, $detail) {
  return @"
    <div class="diagram-step" data-step="$num">
      <h4>$title</h4>
      <p>$detail</p>
    </div>
"@
}

function Build-Steps($title, $items) {
  $i = 0
  $steps = ($items | ForEach-Object { $i++; Step $i $_.title $_.detail }) -join "`n"
  return @"
<div class="visual">
  <div class="visual-title">$title</div>
  <div class="edu-diagram">
    <div class="diagram-steps">
$steps
    </div>
  </div>
</div>
"@
}

function Replace-Visual($fileName, $oldTitle, $newHtml) {
  $path = Join-Path $Root $fileName
  $html = [IO.File]::ReadAllText($path, $PageEncoding)
  $pattern = '(?s)<div class="visual">\s*<div class="visual-title">' + [regex]::Escape($oldTitle) + '</div>\s*<div class="diagram-lines">.*?</div>\s*<p class="diagram-hint">.*?</p>\s*</div>'
  $count = ([regex]::Matches($html, $pattern)).Count
  if ($count -ne 1) {
    throw "Expected one match for $fileName / $oldTitle, found $count"
  }
  $updated = [regex]::Replace($html, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $newHtml }, 1)
  [IO.File]::WriteAllText($path, $updated, $PageEncoding)
}

$k3 = @(
  @{code='K3-1'; title='文本插值'; detail='<code>{{ }}</code> 用于响应式文本展示，不能直接放在属性位置。'},
  @{code='K3-2'; title='属性绑定'; detail='<code>v-bind</code> / <code>:</code> 绑定属性，支持 class/style 对象与数组。'},
  @{code='K3-3'; title='事件绑定'; detail='<code>v-on</code> / <code>@</code> 绑定交互事件，必要时接收 <code>$event</code>。'},
  @{code='K3-4'; title='双向绑定'; detail='<code>v-model</code> 等价于值绑定加输入事件，适合表单状态。'},
  @{code='K3-5'; title='条件渲染'; detail='<code>v-if</code> 控制创建销毁，<code>v-show</code> 适合频繁切换。'},
  @{code='K3-6'; title='列表渲染'; detail='<code>v-for</code> 配合稳定唯一 <code>:key</code>，让更新更可靠。'},
  @{code='K3-7'; title='修饰符'; detail='<code>.stop</code>、<code>.prevent</code>、<code>.lazy</code> 等压缩常见细节。'}
)
Replace-Visual '03-教学资料-模板语法与指令.html' '图示 1：结构与流程重绘' (Build-Grid '图示 1：模板语法与指令知识地图' 'three' $k3)

$reactivity = @"
<div class="visual">
  <div class="visual-title">图示 1：Vue 响应式读写触发链</div>
  <div class="edu-diagram">
    <div class="diagram-flow">
      <div class="diagram-card"><strong>get</strong><h4>读取属性</h4><p>组件渲染或副作用读取响应式属性。</p></div>
      <div class="flow-arrow">→</div>
      <div class="diagram-card"><strong>track</strong><h4>收集依赖</h4><p>记录“谁用了这个属性”，建立属性到副作用的关系。</p></div>
      <div class="flow-arrow">→</div>
      <div class="diagram-card"><strong>set</strong><h4>修改属性</h4><p>数据变化进入代理拦截逻辑。</p></div>
      <div class="flow-arrow">→</div>
      <div class="diagram-card"><strong>trigger</strong><h4>触发更新</h4><p>通知相关依赖重新执行或重新渲染。</p></div>
    </div>
  </div>
</div>
"@
Replace-Visual '04-教学资料-响应式系统.html' '图示 1：结构与流程重绘' $reactivity

$k4 = @(
  @{code='K4-1'; title='ref'; detail='适合基本类型，脚本中用 <code>.value</code>，模板中自动解包。'},
  @{code='K4-2'; title='reactive'; detail='适合对象和数组，直接访问属性；解构时配合 <code>toRefs</code>。'},
  @{code='K4-3'; title='computed'; detail='声明派生数据，具备缓存，保持纯函数思路。'},
  @{code='K4-4'; title='watch'; detail='显式监听数据源，可拿新旧值，支持 deep 与 immediate。'},
  @{code='K4-5'; title='watchEffect'; detail='立即执行并自动收集依赖，适合不关心旧值的副作用。'},
  @{code='K4-6'; title='Proxy 原理'; detail='通过代理完成依赖收集与触发更新，覆盖属性增删和数组索引。'}
)
Replace-Visual '04-教学资料-响应式系统.html' '图示 2：结构与流程重绘' (Build-Grid '图示 2：响应式系统知识地图' 'three' $k4)

$k5 = @(
  @{code='K5-1'; title='事件处理'; detail='<code>@</code> 绑定事件，区分方法引用、内联表达式与 <code>$event</code>。'},
  @{code='K5-2'; title='事件修饰符'; detail='<code>.stop</code>、<code>.prevent</code>、<code>.once</code> 等处理传播和默认行为。'},
  @{code='K5-3'; title='按键与系统修饰符'; detail='<code>.enter</code>、<code>.esc</code>、<code>.ctrl</code>、<code>.exact</code> 表达快捷键条件。'},
  @{code='K5-4'; title='表单绑定'; detail='文本、单选、复选、下拉都通过 <code>v-model</code> 管理输入状态。'},
  @{code='K5-5'; title='v-model 修饰符'; detail='<code>.lazy</code>、<code>.number</code>、<code>.trim</code> 处理输入时机和格式。'},
  @{code='K5-6'; title='表单验证'; detail='围绕非空、格式、长度生成 errors，并把错误反馈到界面。'}
)
Replace-Visual '05-教学资料-事件处理与表单绑定.html' '图示 1：结构与流程重绘' (Build-Grid '图示 1：事件处理与表单绑定知识地图' 'three' $k5)

$k6 = @(
  @{code='K6-1'; title='条件渲染'; detail='<code>v-if</code>、<code>v-else</code>、<code>v-show</code> 根据切换频率选择。'},
  @{code='K6-2'; title='列表 key'; detail='<code>v-for</code> 必须搭配唯一稳定的 <code>:key</code>，避免用 index。'},
  @{code='K6-3'; title='列表更新检测'; detail='变异方法触发更新，非变异方法用新数组替换；Vue3 可监测索引。'},
  @{code='K6-4'; title='class 绑定'; detail='对象、数组、混合写法都能和普通 class 共存。'},
  @{code='K6-5'; title='style 绑定'; detail='样式对象支持驼峰或带引号短横线，数值通常要带单位。'}
)
Replace-Visual '06-教学资料-条件渲染列表渲染与样式绑定.html' '图示 1：结构与流程重绘' (Build-Grid '图示 1：渲染与样式绑定知识地图' 'three' $k6)

$k7 = @(
  @{code='K7-1'; title='组件注册'; detail='局部组件通过 import 即用，全局组件通过 <code>app.component</code> 注册。'},
  @{code='K7-2'; title='props'; detail='<code>defineProps</code> 描述类型、默认值、必填和校验，保持单向数据流。'},
  @{code='K7-3'; title='emits'; detail='<code>defineEmits</code> 声明事件，子组件通过 emit 把变化交给父组件。'},
  @{code='K7-4'; title='父子通信'; detail='父传子用 props，子传父用 emits，职责边界清晰。'},
  @{code='K7-5'; title='组件 v-model'; detail='基于 <code>modelValue</code> 与 <code>update:modelValue</code>，也可用 <code>defineModel</code>。'}
)
Replace-Visual '07-教学资料-组件基础与组件通信.html' '图示 1：结构与流程重绘' (Build-Grid '图示 1：组件基础与通信知识地图' 'three' $k7)

$k8 = @(
  @{code='K8-1'; title='默认插槽'; detail='<code>&lt;slot&gt;</code> 接收父组件内容，并可设置后备内容。'},
  @{code='K8-2'; title='具名插槽'; detail='通过 name 与 <code>#name</code> 把页面拆成多个内容区域。'},
  @{code='K8-3'; title='作用域插槽'; detail='子组件把数据交给父组件模板，父组件决定如何展示。'},
  @{code='K8-4'; title='动态组件'; detail='<code>&lt;component :is&gt;</code> 切换组件，配合 keep-alive 做缓存。'},
  @{code='K8-5'; title='异步组件'; detail='<code>defineAsyncComponent</code> 按需加载，降低首屏负担。'}
)
Replace-Visual '08-教学资料-插槽与组件高级特性.html' '图示 1：结构与流程重绘' (Build-Grid '图示 1：插槽与组件高级特性知识地图' 'three' $k8)

$k9 = @(
  @{code='K9-1'; title='拆分原则'; detail='围绕单一职责、复用价值、命名一致性和层次边界拆组件。'},
  @{code='K9-2'; title='布局组件'; detail='Header、Sidebar、Content 承担页面骨架，不混入业务细节。'},
  @{code='K9-3'; title='列表组件'; detail='ProjectList、TaskList 通过 props 接收数据，专注列表展示。'},
  @{code='K9-4'; title='表单组件'; detail='LoginForm、SubmitForm 负责输入收集，通过 emits 提交结果。'},
  @{code='K9-5'; title='通用组件'; detail='Pagination、Card、Dialog 抽象高频 UI 能力，服务多个页面。'}
)
Replace-Visual '09-教学资料-组件化开发综合实践.html' '图示 1：结构与流程重绘' (Build-Grid '图示 1：组件化开发实践知识地图' 'three' $k9)

$k10 = @(
  @{code='K10-1'; title='概念与安装'; detail='理解 SPA 路由、hash/history 模式，并用 <code>createRouter</code> 创建路由。'},
  @{code='K10-2'; title='配置与组件'; detail='配置 routes，使用 <code>router-view</code> 和 <code>router-link</code> 承载页面切换。'},
  @{code='K10-3'; title='组合式 API'; detail='<code>useRouter</code> 负责跳转，<code>useRoute</code> 读取当前路由信息。'},
  @{code='K10-4'; title='动态路由'; detail='<code>:id</code> 携带参数，页面通过 params 或 props 获取数据。'},
  @{code='K10-5'; title='嵌套路由'; detail='children 描述父子页面关系，子页面由子 <code>router-view</code> 显示。'}
)
Replace-Visual '10-教学资料-Vue Router基础.html' '图示 1：结构与流程重绘' (Build-Grid '图示 1：Vue Router 基础知识地图' 'three' $k10)

$guardSteps = @(
  @{title='导航触发'; detail='用户点击链接、调用 push，或地址栏发生变化。'},
  @{title='beforeEach'; detail='全局前置守卫先做登录、角色等通用判断。'},
  @{title='beforeEnter'; detail='路由独享守卫处理当前路由的专属规则。'},
  @{title='beforeRouteEnter'; detail='组件进入前守卫处理组件级准备逻辑。'},
  @{title='afterEach'; detail='全局后置守卫收尾，例如记录日志或设置标题。'}
)
Replace-Visual '11-教学资料-路由进阶与导航守卫.html' '图示 1：结构与流程重绘' (Build-Steps '图示 1：导航守卫执行顺序' $guardSteps)

$k11 = @(
  @{code='K11-1'; title='全局守卫'; detail='<code>beforeEach</code> / <code>afterEach</code> 处理全站级导航控制。'},
  @{code='K11-2'; title='独享与组件内守卫'; detail='<code>beforeEnter</code> 管当前路由，组件内守卫处理离开和更新。'},
  @{code='K11-3'; title='meta 元信息'; detail='把权限、角色、标题等放入 meta，守卫从 <code>to.meta</code> 读取。'},
  @{code='K11-4'; title='路由懒加载'; detail='<code>() =&gt; import()</code> 让路由组件按需加载，形成代码分割。'},
  @{code='K11-5'; title='重定向与 404'; detail='<code>redirect</code> 处理跳转，<code>:pathMatch(.*)*</code> 兜底未匹配页面。'}
)
Replace-Visual '11-教学资料-路由进阶与导航守卫.html' '图示 2：结构与流程重绘' (Build-Grid '图示 2：路由进阶知识地图' 'three' $k11)

$k12 = @(
  @{code='K12-1'; title='Pinia 简介'; detail='Vue3 推荐状态库，没有 mutations，写法比 Vuex 更轻。'},
  @{code='K12-2'; title='defineStore'; detail='通过 id 加配置创建 store，支持选项式和组合式写法。'},
  @{code='K12-3'; title='state'; detail='状态由函数返回，可直接修改或用 <code>$patch</code> 批量更新。'},
  @{code='K12-4'; title='getters'; detail='类似计算属性，缓存派生状态，也能在 getter 间互访。'},
  @{code='K12-5'; title='actions'; detail='封装业务方法，可通过 this 访问状态，也支持异步请求。'}
)
Replace-Visual '12-教学资料-Pinia状态管理基础.html' '图示 1：结构与流程重绘' (Build-Grid '图示 1：Pinia 基础知识地图' 'three' $k12)

$storeTree = @"
<div class="visual">
  <div class="visual-title">图示 1：src/stores 状态模块目录</div>
  <div class="edu-diagram">
    <div class="diagram-code-tree">
      <ul>
        <li><span class="tree-label">src/stores/</span></li>
        <li>user.js <span class="tree-comment"># 登录用户、Token、角色权限</span></li>
        <li>project.js <span class="tree-comment"># 项目列表、项目详情与筛选条件</span></li>
        <li>app.js <span class="tree-comment"># 全局加载态、菜单、系统配置</span></li>
      </ul>
    </div>
  </div>
</div>
"@
Replace-Visual '13-教学资料-Pinia进阶与状态管理实践.html' '图示 1：结构与流程重绘' $storeTree

$k13 = @(
  @{code='K13-1'; title='多 store 拆分'; detail='按 user、project、app 分类，让状态职责不混在一起。'},
  @{code='K13-2'; title='store 间引用'; detail='在 action 内调用其他 store，完成跨模块协作。'},
  @{code='K13-3'; title='状态持久化'; detail='通过 localStorage、<code>$subscribe</code> 或插件保留关键状态。'},
  @{code='K13-4'; title='维护 API'; detail='<code>$reset</code>、<code>$patch</code>、<code>$subscribe</code> 管理重置、批量更新和订阅。'},
  @{code='K13-5'; title='CTTS 实践'; detail='用三类 store 支撑登录、项目数据和全局 UI 状态。'}
)
Replace-Visual '13-教学资料-Pinia进阶与状态管理实践.html' '图示 2：结构与流程重绘' (Build-Grid '图示 2：Pinia 进阶知识地图' 'three' $k13)

$proxyFlow = @"
<div class="visual">
  <div class="visual-title">图示 1：Vite 代理请求链路</div>
  <div class="edu-diagram">
    <div class="diagram-flow">
      <div class="diagram-card"><strong>浏览器</strong><h4>前端请求</h4><p><code>/api/projects</code> 从页面或 Axios 发出。</p></div>
      <div class="flow-arrow">→</div>
      <div class="diagram-card"><strong>Vite</strong><h4>代理转发</h4><p>开发服务器识别 <code>/api</code>，把请求转给后端地址。</p></div>
      <div class="flow-arrow">→</div>
      <div class="diagram-card"><strong>Backend</strong><h4>真实接口</h4><p><code>http://localhost:8080/projects</code> 返回业务数据。</p></div>
      <div class="flow-arrow">→</div>
      <div class="diagram-card"><strong>Response</strong><h4>数据回到前端</h4><p>响应经代理返回，组件更新列表或状态。</p></div>
    </div>
  </div>
</div>
"@
Replace-Visual '14-教学资料-Axios网络请求与接口联调.html' '图示 1：结构与流程重绘' $proxyFlow

$k14 = @(
  @{code='K14-1'; title='Axios 基础'; detail='掌握 get/post，请求完成后通常读取 <code>res.data</code>。'},
  @{code='K14-2'; title='请求封装'; detail='创建实例，统一 baseURL、timeout，并按 api 模块拆分接口。'},
  @{code='K14-3'; title='请求拦截器'; detail='请求发出前自动附加 Token 等公共信息。'},
  @{code='K14-4'; title='响应拦截器'; detail='统一解包数据、处理错误，并在 401 时跳转登录。'},
  @{code='K14-5'; title='联调与代理'; detail='用 Vite proxy 解决开发跨域，必要时用 Mock 兜底。'}
)
Replace-Visual '14-教学资料-Axios网络请求与接口联调.html' '图示 2：结构与流程重绘' (Build-Grid '图示 2：Axios 联调知识地图' 'three' $k14)

$srcTree = @"
<div class="visual">
  <div class="visual-title">图示 1：CTTS 前端核心目录结构</div>
  <div class="edu-diagram">
    <div class="diagram-code-tree">
      <ul>
        <li><span class="tree-label">src/</span></li>
        <li>api/ <span class="tree-comment"># 接口模块</span></li>
        <li>components/ <span class="tree-comment"># 通用组件</span></li>
        <li>views/ <span class="tree-comment"># 页面组件</span></li>
        <li>stores/ <span class="tree-comment"># Pinia store</span></li>
        <li>router/ <span class="tree-comment"># 路由配置</span></li>
        <li>utils/ <span class="tree-comment"># request 等工具</span></li>
        <li>App.vue <span class="tree-comment"># 应用根组件</span></li>
        <li>main.js <span class="tree-comment"># 应用入口</span></li>
      </ul>
    </div>
  </div>
</div>
"@
Replace-Visual '15-教学资料-综合项目实践一核心页面与组件开发.html' '图示 1：结构与流程重绘' $srcTree

$k15 = @(
  @{code='K15-1'; title='页面规划'; detail='围绕 10 个页面和目录结构先确定项目骨架。'},
  @{code='K15-2'; title='登录与布局'; detail='登录调接口存 Token，布局从 store 读取用户信息。'},
  @{code='K15-3'; title='列表与详情'; detail='列表支持分页筛选，详情页通过动态路由 props 获取目标数据。'},
  @{code='K15-4'; title='表单页'; detail='提交与评审通过 POST 接口串起业务动作。'},
  @{code='K15-5'; title='用户管理'; detail='管理员完成 CRUD，并结合角色权限控制入口。'}
)
Replace-Visual '15-教学资料-综合项目实践一核心页面与组件开发.html' '图示 2：结构与流程重绘' (Build-Grid '图示 2：核心页面与组件实践知识地图' 'three' $k15)

$distTree = @"
<div class="visual">
  <div class="visual-title">图示 1：Vite 构建产物 dist 目录</div>
  <div class="edu-diagram">
    <div class="diagram-code-tree">
      <ul>
        <li><span class="tree-label">dist/</span></li>
        <li>index.html <span class="tree-comment"># 部署入口 HTML</span></li>
        <li>assets/
          <ul>
            <li>index-xxxx.js <span class="tree-comment"># 打包后的 JS，文件名带哈希</span></li>
            <li>index-xxxx.css <span class="tree-comment"># 打包后的 CSS</span></li>
            <li>... <span class="tree-comment"># 图片、字体等其他静态资源</span></li>
          </ul>
        </li>
      </ul>
    </div>
  </div>
</div>
"@
Replace-Visual '16-教学资料-综合项目实践二路由整合与项目部署.html' '图示 1：结构与流程重绘' $distTree

$workflow = @(
  @{title='登录'; detail='获取身份信息与 Token，进入业务系统。'},
  @{title='项目列表'; detail='查看项目集合，进入指定项目上下文。'},
  @{title='任务列表'; detail='按项目查看任务并筛选当前工作项。'},
  @{title='任务详情'; detail='确认任务要求、状态和提交入口。'},
  @{title='成果提交'; detail='填写成果信息并提交到接口。'},
  @{title='评审'; detail='管理员或教师完成审核反馈。'},
  @{title='用户管理'; detail='维护账号、角色和权限。'},
  @{title='退出'; detail='清理登录状态，回到登录入口。'}
)
Replace-Visual '16-教学资料-综合项目实践二路由整合与项目部署.html' '图示 2：结构与流程重绘' (Build-Steps '图示 2：CTTS 前端业务流程' $workflow)

$k16 = @(
  @{code='K16-1'; title='路由整合'; detail='全路由表、meta、守卫与 404 形成完整访问控制。'},
  @{code='K16-2'; title='状态整合'; detail='三类 store 接入页面，让用户、项目和全局状态协同。'},
  @{code='K16-3'; title='接口联调'; detail='用真实接口逐步替换 Mock，检查请求、响应和错误处理。'},
  @{code='K16-4'; title='vite build'; detail='构建 dist 产物，并通过预览确认生产效果。'},
  @{code='K16-5'; title='部署与答辩'; detail='部署到 Nginx 或平台，准备演示路径和答辩说明。'}
)
Replace-Visual '16-教学资料-综合项目实践二路由整合与项目部署.html' '图示 3：结构与流程重绘' (Build-Grid '图示 3：项目整合与部署知识地图' 'three' $k16)

Write-Host 'mvvm diagrams refined.'
