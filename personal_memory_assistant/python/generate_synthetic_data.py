from faker import Faker
import pandas as pd
import random
from datetime import datetime, timedelta
import numpy as np

# Initialize Faker
fake = Faker()

# Function to convert date to Excel serial format
def to_excel_serial(date):
    base_date = datetime(1899, 12, 30)
    delta = date - base_date
    return delta.days + delta.seconds / 86400

# Function to convert Timestamp to Excel serial
def timestamp_to_serial(value):
    if isinstance(value, pd.Timestamp):
        return to_excel_serial(value.to_pydatetime())
    return value

# Function to standardize priority
def standardize_priority(value):
    if isinstance(value, str):
        value = value.strip().lower()
        if value == "high":
            return "High"
        elif value == "medium":
            return "Medium"
        elif value == "low":
            return "Low"
    return value

# Function to standardize feature values
def standardize_course(value):
    if isinstance(value, str):
        value = value.strip().title()
        mappings = {
            'Iot': 'IoT', 'Embedded Systems And Iot': 'IoT',
            'Cloud Computing': 'Cloud Computing',
            'Aiml': 'AIML', 'Ml': 'AIML',
            'Dbms': 'DBMS', 'Database Management System': 'DBMS',
            'Oose': 'OOSE',
            'Cse': 'CSE', 'Computer Science Engineering': 'CSE',
            'Toc': 'TOC', 'Big Data Analytics': 'Big Data Analytics',
            'Not Course Related': 'Not Course Related', 'Not Course Related Task': 'Not Course Related',
            'Renewable Energy': 'Renewable Energy', 'Renewable Energy System': 'Renewable Energy',
            'Video Editing And Creation': 'Video Editing', 'Video Creation And Editing': 'Video Editing',
            'Renewable': 'Renewable Energy',
            'Ios': 'Ios', 'It': 'It', 'None': 'Not Course Related'
        }
        return mappings.get(value, value)
    return value

def standardize_task_type(value):
    if isinstance(value, str):
        value = value.strip().title()
        mappings = {
            'Project': 'Project',
            'Exam Preparation': 'Exam Preparation', 'Xam Preparation': 'Exam Preparation',
            'Quiz Preparation': 'Quiz Preparation',
            'Assignment': 'Assignment', 'Assigment': 'Assignment', 'Written Assignment': 'Assignment',
            'Written Work': 'Written Work',
            'Seminar Preparation': 'Seminar Preparation', 'Seminar': 'Seminar Preparation',
            'Placement Preparation': 'Placement Preparation',
            'Class Test': 'Class Test',
            'Short Flim Making, Post Maker': 'Short Film', 'Short Film': 'Short Film', 'Short Flim': 'Short Film'
        }
        return mappings.get(value, value)
    return value

def standardize_time_taken(value):
    if isinstance(value, str):
        value = value.strip().lower()
        mappings = {
            '>3 hours': '>3 hours', '> 3 hours': '>3 hours',
            '1-2 hours': '1-2 hours', '2-3 hours': '2-3 hours', '1 hour': '1 hour', '30 min': '30 min',
            'weekly thrice': '1 hour', '5min': '30 min', '10min': '30 min'
        }
        return mappings.get(value, value)
    return value

def standardize_location(value):
    if isinstance(value, str):
        value = value.strip().title()
        mappings = {
            'At Home': 'Home', 'Home': 'Home', 'Home,College': 'Home and college',
            'At Home Or College': 'Home and college', 'Home And College': 'Home and college'
        }
        return mappings.get(value, 'Home')
    return value

# Load original data
try:
    tasksurvey = pd.read_excel("data/tasksurvey.xlsx")
    tasksurvey.columns = tasksurvey.columns.str.strip()
    tasksurvey["3.When is the task due?"] = tasksurvey["3.When is the task due?"].apply(timestamp_to_serial)
    tasksurvey["Timestamp"] = tasksurvey["Timestamp"].apply(timestamp_to_serial)
    tasksurvey["8.What is the priority of this task?"] = tasksurvey["8.What is the priority of this task?"].apply(standardize_priority)
    tasksurvey["2.Which course is this task for?"] = tasksurvey["2.Which course is this task for?"].apply(standardize_course)
    tasksurvey["4.What type of task is it?"] = tasksurvey["4.What type of task is it?"].apply(standardize_task_type)
    tasksurvey["5.How much time does this task take?"] = tasksurvey["5.How much time does this task take?"].apply(standardize_time_taken)
    tasksurvey["7.Where do you usually do this task?"] = tasksurvey["7.Where do you usually do this task?"].apply(standardize_location)
    print("TaskSurvey shape:", tasksurvey.shape)
    print("TaskSurvey columns:", tasksurvey.columns.tolist())
    print("TaskSurvey priorities:", tasksurvey["8.What is the priority of this task?"].unique())
except Exception as e:
    print("Error loading tasksurvey.xlsx:", e)
    tasksurvey = pd.DataFrame()

try:
    mytasks = pd.read_excel("data/mytasks.xlsx")
    mytasks.columns = mytasks.columns.str.strip()
    mytasks["3.When is the task due?"] = mytasks["3.When is the task due?"].apply(timestamp_to_serial)
    mytasks["Timestamp"] = mytasks["Timestamp"].apply(timestamp_to_serial)
    mytasks["8.What is the priority of this task?"] = mytasks["8.What is the priority of this task?"].apply(standardize_priority)
    mytasks["2.Which course is this task for?"] = mytasks["2.Which course is this task for?"].apply(standardize_course)
    mytasks["4.What type of task is it?"] = mytasks["4.What type of task is it?"].apply(standardize_task_type)
    mytasks["5.How much time does this task take?"] = mytasks["5.How much time does this task take?"].apply(standardize_time_taken)
    mytasks["7.Where do you usually do this task?"] = mytasks["7.Where do you usually do this task?"].apply(standardize_location)
    print("MyTasks shape:", mytasks.shape)
    print("MyTasks columns:", mytasks.columns.tolist())
    print("MyTasks priorities:", mytasks["8.What is the priority of this task?"].unique())
except Exception as e:
    print("Error loading mytasks.xlsx:", e)
    mytasks = pd.DataFrame()

# Get distributions from real data
real_df = pd.concat([tasksurvey, mytasks], ignore_index=True)
print("Real data distributions:")
print("Courses:\n", real_df["2.Which course is this task for?"].value_counts(normalize=True))
print("Task types:\n", real_df["4.What type of task is it?"].value_counts(normalize=True))
print("Time taken:\n", real_df["5.How much time does this task take?"].value_counts(normalize=True))
print("Locations:\n", real_df["7.Where do you usually do this task?"].value_counts(normalize=True))
print("Priorities:\n", real_df["8.What is the priority of this task?"].value_counts(normalize=True))

# Define exact counts for synthetic data (250 rows)
n_synthetic = 250
priority_counts = {
    "Medium": round(0.383562 * n_synthetic),  # 96
    "Low": round(0.342466 * n_synthetic),     # 86
    "High": round(0.273973 * n_synthetic)     # 68
}
# Adjust to ensure total is 250
total_priority = sum(priority_counts.values())
if total_priority != n_synthetic:
    priority_counts["Medium"] += n_synthetic - total_priority

course_counts = {k: round(v * n_synthetic) for k, v in real_df["2.Which course is this task for?"].value_counts(normalize=True).items()}
total_courses = sum(course_counts.values())
if total_courses != n_synthetic:
    course_counts["Not Course Related"] += n_synthetic - total_courses

task_type_counts = {k: round(v * n_synthetic) for k, v in real_df["4.What type of task is it?"].value_counts(normalize=True).items()}
total_task_types = sum(task_type_counts.values())
if total_task_types != n_synthetic:
    task_type_counts["Exam Preparation"] += n_synthetic - total_task_types

time_taken_counts = {k: round(v * n_synthetic) for k, v in real_df["5.How much time does this task take?"].value_counts(normalize=True).items()}
total_time_taken = sum(time_taken_counts.values())
if total_time_taken != n_synthetic:
    time_taken_counts[">3 hours"] += n_synthetic - total_time_taken

location_counts = {k: round(v * n_synthetic) for k, v in real_df["7.Where do you usually do this task?"].value_counts(normalize=True).items()}
total_locations = sum(location_counts.values())
if total_locations != n_synthetic:
    location_counts["Home"] += n_synthetic - total_locations

year_counts = {k: round(v * n_synthetic) for k, v in real_df["6.Which year are you studying in?"].value_counts(normalize=True).items()}
total_years = sum(year_counts.values())
if total_years != n_synthetic:
    year_counts[list(year_counts.keys())[0]] += n_synthetic - total_years

# Generate synthetic data
synthetic_data = []
for priority, count in priority_counts.items():
    for _ in range(count):
        due_date = fake.date_time_between(start_date="now", end_date="+30d")
        course = np.random.choice(list(course_counts.keys()), p=[v/n_synthetic for v in course_counts.values()])
        task_type = np.random.choice(list(task_type_counts.keys()), p=[v/n_synthetic for v in task_type_counts.values()])
        time = np.random.choice(list(time_taken_counts.keys()), p=[v/n_synthetic for v in time_taken_counts.values()])
        location = np.random.choice(list(location_counts.keys()), p=[v/n_synthetic for v in location_counts.values()])
        year = np.random.choice(list(year_counts.keys()), p=[v/n_synthetic for v in year_counts.values()])
        synthetic_data.append({
            "Timestamp": to_excel_serial(fake.date_time_between(start_date="-30d", end_date="now")),
            "Email address": fake.email(),
            "1. What task do you need to do?": random.choice(["Assignment", "Project", "Seminar", "Study", "Prepare", "Collect dataset"]),
            "2.Which course is this task for?": standardize_course(course),
            "3.When is the task due?": to_excel_serial(due_date),
            "4.What type of task is it?": standardize_task_type(task_type),
            "5.How much time does this task take?": standardize_time_taken(time),
            "6.Which year are you studying in?": year,
            "7.Where do you usually do this task?": standardize_location(location),
            "8.What is the priority of this task?": priority
        })

# Combine original and synthetic data
synthetic_df = pd.DataFrame(synthetic_data)
print("Synthetic shape:", synthetic_df.shape)
print("Synthetic columns:", synthetic_df.columns.tolist())
print("Synthetic data sample:\n", synthetic_df.head())
print("Synthetic data distributions:")
print("Courses:\n", synthetic_df["2.Which course is this task for?"].value_counts(normalize=True))
print("Task types:\n", synthetic_df["4.What type of task is it?"].value_counts(normalize=True))
print("Time taken:\n", synthetic_df["5.How much time does this task take?"].value_counts(normalize=True))
print("Locations:\n", synthetic_df["7.Where do you usually do this task?"].value_counts(normalize=True))
print("Priorities:\n", synthetic_df["8.What is the priority of this task?"].value_counts(normalize=True))

combined_df = pd.concat([tasksurvey, mytasks, synthetic_df], ignore_index=True)
print("Combined shape before cleaning:", combined_df.shape)
print("Combined columns:", combined_df.columns.tolist())
print("Missing values before dropna:\n", combined_df.isnull().sum())

# Clean data (fill NaN for non-critical columns)
combined_df = combined_df.fillna({
    "Email address": "unknown@example.com",
    "1. What task do you need to do?": "Unknown",
    "2.Which course is this task for?": "Not Course Related",
    "4.What type of task is it?": "Other",
    "5.How much time does this task take?": "1 hour",
    "6.Which year are you studying in?": "3rd year",
    "7.Where do you usually do this task?": "Home",
    "8.What is the priority of this task?": "Medium"
})
print("Combined shape after filling NaN:", combined_df.shape)
combined_df["3.When is the task due?"] = combined_df["3.When is the task due?"].astype(float)
combined_df["Timestamp"] = combined_df["Timestamp"].astype(float)

# Save augmented data
combined_df.to_csv("data/augmented_tasks.csv", index=False)
print(f"Generated {len(synthetic_df)} synthetic rows. Total rows: {len(combined_df)}")