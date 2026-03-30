# 🤖 Multi-Agent LLM — نظام الوكلاء المتعددين

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Android](https://img.shields.io/badge/Android-24%2B-green)
![License](https://img.shields.io/badge/License-MIT-blue)

**تطبيق أندرويد لتشغيل نماذج الذكاء الاصطناعي محلياً وإدارة الوكلاء المتعددين**

[English](#english) | [العربية](#العربية)

</div>

---

## العربية 🇸🇦

### 📱 ما هو هذا التطبيق؟

تطبيق أندرويد متكامل يمكنك من:

- 🏠 **تشغيل نماذج GGUF محلياً** على هاتفك (بدون إنترنت)
- 🌐 **التوصيل بـ Ollama** على أجهزة أخرى في نفس الشبكة
- 🔗 **استخدام أي API** متوافق مع OpenAI
- 🤖 **إنشاء وكلاء متخصصين** (مبرمج، مترجم، محلل...)
- ⛓️ **بناء سلاسل مهام** تمر عبر عدة وكلاء بالتسلسل

### 🎯 المميزات الرئيسية

| المميزة | الوصف |
|---------|--------|
| **تشغيل محلي** | نماذج GGUF تعمل مباشرة على جهازك (بدون سيرفر) |
| **اكتشاف Ollama** | يجد تلقائياً أجهزة Ollama على شبكتك المحلية |
| **OpenAI API** | توافق مع أي خدمة تدعم واجهة OpenAI |
| **نظام الوكلاء** | أنشئ وكلاء مخصصين بـ system prompts مختلفة |
| **سلسلة المهام** | اربط وكلاء متعددين في pipeline واحد |
| **Streaming** | استلام النص فوراً أثناء التوليد |
| **Dark Mode** | تصميم أنيق بالوضع الداكن |

### 📲 التثبيت

#### متطلبات
- Android 7.0+ (API 24)
- 4GB RAM على الأقل (للنماذج الصغيرة)
- 8GB RAM+ موصى به (للنماذج المتوسطة)

#### خطوات التثبيت
1. حمّل ملف APK من [الإصدارات](https://github.com/Zarax34/multi-agent-llm/releases)
2. ثبّت التطبيق
3. امنح صلاحيات التخزين

### 🚀 الاستخدام

#### 1. تشغيل نماذج محلية (GGUF)
1. اذهب لشاشة **النماذج** ← اضغط **+**
2. اختر **Import GGUF File**
3. اختر ملف `.gguf` من جهازك
4. اذهب لشاشة **المحادثة** ← اختر النموذج ← ابدأ الدردشة

#### 2. التوصيل بـ Ollama
1. تأكد أن Ollama يعمل على جهاز آخر
2. اذهب لشاشة **Ollama Discovery**
3. اضغط **Scan** للبحث التلقائي
4. أو أدخل عنوان IP يدوياً

#### 3. إنشاء وكيل
1. اذهب لشاشة **الوكلاء** ← اضغط **+**
2. اختر اسم، system prompt، والنموذج
3. احفظ واستخدم في المحادثة

#### 4. بناء سلسلة مهام
1. أنشئ عدة وكلاء
2. اذهب لشاشة **Pipeline** ← اضغط **New Pipeline**
3. اختر الوكلاء ورتّبهم
4. أدخل المهمة واضغط **Run**

### 📥 نماذج مقترحة

| النموذج | الحجم | مناسب لـ |
|---------|-------|---------|
| [Qwen3 0.6B](https://huggingface.co/NobodyWho/Qwen_Qwen3-0.6B-GGUF) | 332MB | تجربة سريعة |
| [Phi-2](https://huggingface.co/microsoft/phi-2) | 1.6GB | محادثات عامة |
| [Llama 3.2 1B](https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF) | 700MB | توازن أداء/جودة |
| [Gemma 2B](https://huggingface.co/google/gemma-2b) | 1.5GB | محادثات متقدمة |

### 🏗️ التقنيات المستخدمة

- **Flutter** — إطار العمل الرئيسي
- **nobodywho** — تشغيل نماذج GGUF محلياً
- **flutter_bloc** — إدارة الحالة
- **Hive** — التخزين المحلي
- **Dio** — الطلبات الشبكية

---

## English 🇺🇸

### What is this app?

An Android application for running AI language models locally and managing multi-agent pipelines:

- 🏠 **Run GGUF models locally** on your phone (offline)
- 🌐 **Connect to Ollama** on other devices on your LAN
- 🔗 **Use any OpenAI-compatible API**
- 🤖 **Create specialized agents** with custom system prompts
- ⛓️ **Build agent pipelines** that chain multiple agents sequentially

### Key Features

| Feature | Description |
|---------|-------------|
| **Local Inference** | GGUF models run directly on device (no server needed) |
| **Ollama Discovery** | Auto-finds Ollama instances on your local network |
| **OpenAI API** | Compatible with any OpenAI-compatible endpoint |
| **Agent System** | Create agents with different models and system prompts |
| **Pipeline** | Chain agents together in sequential pipelines |
| **Streaming** | Real-time token streaming |
| **Dark Mode** | Clean Ollama-inspired dark UI |

### Installation

#### Requirements
- Android 7.0+ (API 24)
- 4GB RAM minimum (for small models)
- 8GB+ RAM recommended (for medium models)

#### Steps
1. Download APK from [Releases](https://github.com/Zarax34/multi-agent-llm/releases)
2. Install the app
3. Grant storage permissions

### Usage

#### Local GGUF Models
1. Go to **Models** screen → tap **+**
2. Choose **Import GGUF File**
3. Select a `.gguf` file from your device
4. Go to **Chat** → select model → start chatting

#### Ollama Connection
1. Ensure Ollama is running on another device
2. Go to **Ollama Discovery** screen
3. Tap **Scan** for auto-discovery
4. Or enter IP address manually

#### Create Agent
1. Go to **Agents** → tap **+**
2. Set name, system prompt, and model
3. Save and use in chat

#### Build Pipeline
1. Create multiple agents
2. Go to **Pipeline** → tap **New Pipeline**
3. Select agents and order them
4. Enter task and tap **Run**

### Recommended Models

| Model | Size | Best For |
|-------|------|---------|
| [Qwen3 0.6B](https://huggingface.co/NobodyWho/Qwen_Qwen3-0.6B-GGUF) | 332MB | Quick testing |
| [Phi-2](https://huggingface.co/microsoft/phi-2) | 1.6GB | General chat |
| [Llama 3.2 1B](https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF) | 700MB | Balanced |
| [Gemma 2B](https://huggingface.co/google/gemma-2b) | 1.5GB | Advanced chat |

### Tech Stack

- **Flutter** — Main framework
- **nobodywho** — Local GGUF inference
- **flutter_bloc** — State management
- **Hive** — Local storage
- **Dio** — HTTP client

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

## 👨‍💻 Developer

**Ahmed** — [GitHub](https://github.com/Zarax34)
