---
name: sc:recommend
description: Ultra-intelligent command recommendation engine - recommends the most suitable SuperClaude commands for any user input
category: utility
---

# SuperClaude Intelligent Command Recommender

**Purpose**: Analyzes user requests and recommends optimal SuperClaude commands with personas, MCP servers, and flags.

## Command
```bash
/sc:recommend [user request] [--options [flags]]
```

## Options
| Flag | Purpose |
|------|---------|
| `--estimate` | Include time and budget estimation |
| `--alternatives` | Provide multiple solution recommendations |
| `--stream` | Continuous project tracking mode |
| `--community` | Include community data |
| `--language [tr\|en\|auto]` | Language setting |
| `--expertise [beginner\|intermediate\|expert]` | Level setting |

## Multi-language Support

### Language Detection
```python
def detect_language(input_text):
    turkish_chars = ['ç', 'ğ', 'ı', 'ö', 'ş', 'ü']
    if any(char in input_text.lower() for char in turkish_chars): return "tr"
    english_common = ["the", "and", "is", "are", "was", "were"]
    if any(word in input_text.lower().split() for word in english_common): return "en"
    return "en"  # Default
```

### Multi-language Examples
```bash
/sc:recommend "makine öğrenmesi algoritması başlat"    # Turkish
/sc:recommend "I want to build ML algorithm"            # English
/sc:recommend "makine learning projesi yapmak istiyorum" # Mixed
```

## Keyword Extraction and Category Mapping

```yaml
keyword_patterns:
  # ML & Data
  "machine learning|ml|ai|artificial intelligence": ml_category + --persona-analyzer
  "data|database|sql": data_category + --persona-backend
  "model|algorithm|prediction|classify": ml_category + --persona-architect

  # Web Development
  "website|frontend|ui/ux": web_category + --persona-frontend
  "react|vue|angular|component": web_category + --persona-frontend --magic
  "api|backend|server|microservice": api_category + --persona-backend

  # Debugging & Performance
  "error|bug|issue|not working": debug_category + --persona-analyzer
  "slow|performance|optimization": performance_category + --persona-performance
  "security|auth|vulnerability": security_category + --persona-security

  # Development & Learning
  "new|create|build|develop|feature": create_category + --persona-frontend|backend
  "design|architecture": design_category + --persona-architect
  "test|qa|quality|validation": test_category + --persona-qa
  "how|learn|explain|tutorial": learning_category + --persona-mentor
  "refactor|cleanup|improve|quality": improve_category + --persona-refactorer

  # Context analysis
  "beginner|starter|just started": beginner_level + --persona-mentor
  "expert|senior|experienced": expert_level + --persona-architect
```

## Command Map by Category

| Category | Primary Commands | MCP Servers | Personas | Key Flags |
|----------|-----------------|-------------|----------|-----------|
| ML | `/sc:analyze --seq --c7`, `/sc:design --seq --ultrathink` | `--c7`, `--seq` | analyzer, architect | `--think-hard`, `--evidence`, `--profile` |
| Web | `/sc:build --feature --magic`, `/sc:design --api --seq` | `--magic`, `--c7`, `--pup` | frontend, qa | `--react`, `--tdd`, `--validate` |
| API | `/sc:design --api --ddd --seq`, `/sc:build --feature --tdd` | `--seq`, `--c7`, `--pup` | backend, security | `--microservices`, `--ultrathink`, `--security` |
| Debug | `/sc:troubleshoot --investigate --seq`, `/sc:analyze --code --seq` | `--seq`, `--all-mcp` | analyzer, security | `--evidence`, `--think-hard`, `--profile` |
| Performance | `/sc:analyze --performance --pup --profile`, `/sc:troubleshoot --seq` | `--pup`, `--seq` | performance, analyzer | `--profile`, `--monitoring`, `--benchmark` |
| Security | `/sc:scan --security --owasp --deps`, `/sc:analyze --security --seq` | `--seq` | security, analyzer | `--strict`, `--validate`, `--owasp` |
| Create | `/sc:build --feature --tdd`, `/sc:design --seq --ultrathink` | `--magic`, `--c7`, `--pup` | frontend, backend, architect | `--interactive`, `--plan`, `--think` |
| Test | `/sc:test --coverage --e2e --pup`, `/sc:scan --validate` | `--pup` | qa, performance | `--validate`, `--coverage`, `--monitoring` |
| Improve | `/sc:improve --quality --iterate`, `/sc:cleanup --code --all` | `--seq` | refactorer, mentor | `--threshold`, `--iterate`, `--profile` |
| Learning | `/sc:document --user --examples`, `/sc:analyze --code --c7` | `--c7` | mentor, analyzer | `--examples`, `--visual`, `--interactive` |

## Expertise Level Customization

| Level | Style | Commands | Behavior |
|-------|-------|----------|----------|
| Beginner | Detailed, step-by-step | `/sc:brainstorm --educational`, `/sc:help --interactive` | Extra explanations, step-by-step |
| Intermediate | Balanced, technical | `/sc:implement --guided`, `/sc:design --template` | Some explanations |
| Expert | Fast, technical, direct | `/sc:implement --advanced`, `/sc:analyze --deep` | Minimal explanations |

## Project Context Detection

```yaml
project_detection:
  react_project:
    indicators: ["package.json with react", "src/App.jsx", "public/"]
    commands: ["/sc:build --feature --magic --react", "/sc:test --coverage --e2e --pup"]
    personas: ["--persona-frontend", "--persona-qa"]

  vue_project:
    indicators: ["package.json with vue", "src/App.vue", "vue.config.js"]
    commands: ["/sc:build --feature --magic", "/sc:analyze --code --c7"]

  node_api_project:
    indicators: ["package.json with express", "server.js", "routes/"]
    commands: ["/sc:design --api --ddd --seq", "/sc:build --feature --tdd"]
    personas: ["--persona-backend", "--persona-security"]

  python_project:
    indicators: ["requirements.txt", "setup.py", "src/", "main.py"]
    commands: ["/sc:analyze --code --seq", "/sc:design --seq --ultrathink"]

  database_project:
    indicators: ["schema.sql", "migrations/", "models/", "prisma.schema"]
    commands: ["/sc:migrate --database --validate", "/sc:analyze --security --seq"]

project_size:
  small: "<50 files → direct implementation"
  medium: "50-200 files → plan → analyze → implement"
  large: ">200 files → comprehensive analysis → design → implement"
```

## Streaming Mode

```yaml
streaming_mode:
  command: "/sc:recommend --stream [project description]"
  phases:
    1_analysis: { commands: ["/sc:analyze", "/sc:design"], trigger: "analysis_complete" }
    2_implementation: { commands: ["/sc:build", "/sc:implement"], trigger: "implementation_complete" }
    3_testing: { commands: ["/sc:test", "/sc:scan"], trigger: "testing_complete" }
    4_deployment: { commands: ["/sc:deploy", "/sc:improve"], trigger: "project_complete" }
```

## Alternative Recommendations

When `--alternatives` is used, provide:
- Primary recommendation (most suitable)
- 2-3 alternatives with advantage/disadvantage analysis
- Comparison table (Speed, SEO, Learning, Community)
- Community preference percentage

## Time and Budget Estimation

```yaml
estimation_factors:
  project_type:
    simple_component: 1-3 days
    feature_development: 1-2 weeks
    microservice: 2-4 weeks
    full_application: 1-3 months
    enterprise_system: 3-6 months

  experience_multiplier: { beginner: 2.0x, intermediate: 1.5x, expert: 1.0x, senior: 0.8x }
  scope_multiplier: { small: 1.0x, medium: 1.5x, large: 2.5x, enterprise: 4.0x }

  ml_time_distribution: { data_collection: 20-30%, preprocessing: 15-25%, model_training: 10-20%, evaluation: 10-15%, deployment: 15-25% }
  web_time_distribution: { design: 15-25%, frontend: 30-40%, backend: 25-35%, testing: 10-20%, deployment: 5-15% }
```

## Smart Flag Recommendations

```yaml
smart_flags:
  by_project_size: { small: "--quick --simple", medium: "--plan --validate --profile", large: "--plan --validate --seq --ultrathink" }
  by_security: { basic: "--basic-security", standard: "--security --validate", enterprise: "--security --owasp --strict --audit" }
  by_performance: { low: "--basic-optimization", medium: "--optimize --profile", high: "--optimize --profile --monitoring --benchmark" }
  by_learning: { beginner: "--tutorial --examples --step-by-step", intermediate: "--guided --examples", expert: "--advanced --no-explanations" }

  by_history:
    previous_errors: "--validate --dry-run --backup"
    security_issues: "--security --scan --strict"
    performance_issues: "--profile --optimize --monitor"
    large_refactor: "--plan --backup --validate"

  by_project_type:
    ml: "--data-validation --model-monitoring"
    api: "--security --rate-limiting --monitoring"
    frontend: "--accessibility --responsive --performance"
    mobile: "--offline --sync --battery-optimized"
```

## Community Patterns

```yaml
successful_workflows:
  web_development:
    flow: ["/sc:analyze --code --c7", "/sc:design --api --seq", "/sc:build --feature --magic --tdd", "/sc:test --coverage --e2e --pup"]
    success_rate: "87%"

  ml_development:
    flow: ["/sc:analyze --seq --c7 --persona-mentor", "/sc:design --seq --ultrathink --persona-architect", "/sc:build --feature --tdd", "/sc:improve --performance --iterate"]
    success_rate: "82%"

popular_combinations:
  security_focused: ["/sc:scan --security --owasp", "/sc:analyze --security --seq", "/sc:improve --security --harden"]
  performance: ["/sc:analyze --performance --pup --profile", "/sc:improve --performance --iterate", "/sc:test --coverage --benchmark"]

user_preferences:
  stacks: { react: "65%", nextjs: "42%", python_ml: "78%", nodejs_api: "71%" }
  approaches: { tdd: "58%", iterative: "73%", security_first: "67%" }
```

## Response Format

```yaml
response:
  header: [project_analysis, language_detection, level_determination, persona_recommendation, project_context]
  recommendations: [main_commands(3), additional(optional), smart_flags, quick_start]
  enhanced (--estimate): [time_breakdown, budget, risk_assessment, critical_factors]
  enhanced (--alternatives): [technology_options, comparison_table, community_preference]
  enhanced (--community): [successful_flows, popular_combinations, common_risks]
  enhanced (--stream): [phase_tracking, continuous_recommendations]
```

## Example Output

```bash
/sc:recommend "I'm building an e-commerce site" --estimate --alternatives --community

🎯 Analysis: E-commerce | Lang: Turkish | Level: Intermediate
🎭 Personas: architect + frontend + security

✅ RECOMMENDATIONS:
1. /sc:design --api --ddd --seq --ultrathink --persona-architect
2. /sc:build --feature --magic --nextjs --persona-frontend
3. /sc:build --feature --tdd --persona-security

🔧 FLAGS: --security --owasp --strict --optimize --monitoring --cdn
⭐ BEST: Next.js + Stripe + PostgreSQL (42% community)
⏱️ ESTIMATE: 6-12 weeks | Solo: 240-480h | Team: 480-1440h
👥 COMMUNITY: analyze→design→build→test→deploy (87% success)
⚠️ RISKS: Payment security (32%), Performance scaling (28%), Tax complexity (45%)
```

## Quick Usage
```bash
/sc:recommend "I want to do something"
/sc:recommend "new React project" --estimate --alternatives
/sc:recommend --stream "I'm developing my e-commerce site"
/sc:recommend "I want to learn React" --expertise beginner
/sc:recommend "blog site" --community
```
