# FSL Learn — Filipino Sign Language Vocabulary Learning Platform

Welcome to the **FSL Learn System User Manual**. FSL Learn (also branded as **FSLearn**) is an interactive, web-based educational platform designed to teach Filipino Sign Language (FSL) vocabulary. Built specifically for elementary and Special Education (SPED) environments, such as Tomas Sagun Integrated School, the platform bridges communication barriers for Deaf and hard-of-hearing learners, teachers, and hearing peers.

The system addresses the severe shortage of localized, accessible, and structured digital tools for learning Filipino Sign Language. By combining visual sign demonstrations, interactive vocabulary learning, graded practice, multiple-choice quizzes, and computer-vision-assisted hand sign recognition, FSL Learn offers an engaging and supportive learning environment for Filipino classrooms.

!!! note
    System Version: **2.0.0**  
    Manual Release Date: **November 2026**  
    Architecture: PHP 8.x (Apache / PDO) backend with a FastAPI Python 3 Machine Learning service.

## Who This Manual Is For

This user manual is designed for the three primary user roles operating the platform:

- **Students (Learners)**: Young learners and SPED pupils who browse sign lessons across three progressive levels (Alphabet, Basic, and Intermediate), watch animated sign demonstrations, complete lessons, and take interactive mastery quizzes.
- **Teachers**: Educators who establish virtual classrooms, enroll and monitor student progress, oversee quiz performance and accuracy metrics, and conduct live classroom demonstrations using AI hand recognition.
- **Principal (Administrator)**: School administrators who oversee institutional performance, generate and manage cryptographically secure Teacher Registration Codes, and generate official school-wide progress reports.

## Key System Features

FSL Learn provides comprehensive educational and administrative capabilities:

- **Structured Three-Tier Curriculum**:
    - **Alphabet**: 26 letters of the FSL alphabet with letter cards and hand demonstration animations.
    - **Basic Vocabulary**: 15 thematic categories covering Numbers, Colors, Fruits, Vegetables, Family, Shapes, Animals, Body Parts, Food and Drinks, School Objects, School Subjects, Time, Weather, Everyday Greetings, and H-Questions.
    - **Intermediate Vocabulary**: 9 advanced categories covering Occupations, Transportation, Hobbies, Daily Routine, Emergencies, Community, Emotions and Opinions, Meet & Greet, and Money Matters.
- **Interactive Demonstrations and Tips**: High-quality animated demonstration GIFs paired with Filipino and English translations, category badges, and actionable signing tips.
- **Multiple-Choice Quizzes**: Automated assessments with immediate visual feedback trays, passing score evaluations (70% benchmark), and permanent database scoring.
- **Classroom Management & Unique Join Codes**: Teachers create isolated classroom sections, generate 6-character alphanumeric join codes (e.g., `QPELNG`), and maintain a one-classroom-per-student enrollment policy.
- **Live Alphabet Hand Recognition ("Sign & Spell")**: Real-time camera feed analysis using Google MediaPipe Hands (21 3D landmarks) and a Scikit-learn Random Forest model to verify hand signs live in the browser.
- **Administrative Code Generator**: Two-factor re-authenticated code generation allowing the Principal to produce 16-character registration codes (`FSL-XXXXXXXX-XXXXXXXX`) with configurable expiration windows.
- **School-Wide Analytics and Exportable Reporting**: Consolidated performance reporting filterable by School Year, Grade Level, and Section, with one-click export to PDF and CSV formats.

## System Verification Preview

To verify that the platform's dual-backend architecture is operational, administrators can query the ML service health endpoint using a terminal command:

```powershell
curl -X GET http://127.0.0.1:8000/api/health
```

A healthy system responds with a JSON status payload confirming that the computer vision service is active:

```json
{
  "status": "ok",
  "app": "FSL Learn ML Service",
  "time": "2026-11-26T15:20:00.000000",
  "info": "DB endpoints are now served by PHP. This service handles /api/recognize only."
}
```

## Documentation Navigation

This manual is organized into four dedicated guides. Consult the table below to find the information relevant to your task:

| Manual Document | Target Audience | Primary Topics Covered |
| :--- | :--- | :--- |
| [Installation Guide](installation.md) | Technical Administrators, IT Staff, Developers | System prerequisites, Laragon/XAMPP setup, Python virtual environment, database schema migration, environment configuration, and verification. |
| [User Guide](usage.md) | Students, Teachers, School Principal | Step-by-step role guides, user authentication, classroom setup, student enrollment, lesson completion, quiz taking, Sign & Spell demo, code generation, and PDF reporting. |
| [Troubleshooting Guide](troubleshooting.md) | All Users, IT Support, Teachers | Diagnosing and resolving common issues including database errors, offline ML service, expired registration codes, classroom enrollment conflicts, and camera permissions. |

For assistance with setting up the software stack from scratch, proceed to the [Installation Guide](installation.md). For end-user instructions and workflows, continue to the [User Guide](usage.md).

[Download the PDF manual](assets/fsl-learn-manual.pdf)
