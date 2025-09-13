from xgboost import XGBClassifier
from sklearn.model_selection import train_test_split, cross_val_score, GridSearchCV
from sklearn.preprocessing import LabelEncoder, StandardScaler
from imblearn.over_sampling import SMOTE
import pandas as pd
import joblib
from datetime import datetime
import numpy as np

# Load augmented data
df = pd.read_csv("data/augmented_tasks.csv")
print("DataFrame shape:", df.shape)
print("Columns:", df.columns.tolist())
print("First 5 rows before cleaning:\n", df.head())

# Feature engineering: Add time until due date
today_serial = (datetime(2025, 5, 1) - datetime(1899, 12, 30)).days
df["days_until_due"] = df["3.When is the task due?"] - today_serial

# Prepare features and target
features = [
    "2.Which course is this task for?",
    "4.What type of task is it?",
    "5.How much time does this task take?",
    "6.Which year are you studying in?",
    "days_until_due"
]
X = df[features].copy()
y = df["8.What is the priority of this task?"]

# Encode categorical features before creating interaction features
le_dict = {}
categorical_cols = [
    "2.Which course is this task for?",
    "4.What type of task is it?",
    "5.How much time does this task take?",
    "6.Which year are you studying in?"
]
for col in categorical_cols:
    le = LabelEncoder()
    X[col] = le.fit_transform(X[col].astype(str)).astype(int)
    le_dict[col] = le

# Add interaction features after encoding
X["course_task_interaction"] = X["2.Which course is this task for?"] * X["4.What type of task is it?"]
X["year_task_interaction"] = X["6.Which year are you studying in?"] * X["4.What type of task is it?"]

# Update features list
features += ["course_task_interaction", "year_task_interaction"]

# Check class balance
print("Priority distribution before SMOTE:\n", y.value_counts())

# Scale days_until_due
scaler = StandardScaler()
X["days_until_due"] = scaler.fit_transform(X[["days_until_due"]]).astype(float)

# Encode target
le_y = LabelEncoder()
y = le_y.fit_transform(y)
print("Encoded priorities:", le_y.classes_)

# Apply SMOTE with sampling strategy
smote = SMOTE(random_state=42, k_neighbors=5, sampling_strategy={0: 124, 1: 124, 2: 124})
X_resampled, y_resampled = smote.fit_resample(X, y)
print("Priority distribution after SMOTE:\n", pd.Series(y_resampled).value_counts())

# Verify data types
print("X dtypes:\n", X.dtypes)

# Split data
print("X_resampled shape:", X_resampled.shape, "y_resampled shape:", y_resampled.shape)
X_train, X_test, y_train, y_test = train_test_split(X_resampled, y_resampled, test_size=0.2, random_state=42)

# Define model
model = XGBClassifier(random_state=42, eval_metric='mlogloss')

# Hyperparameter tuning
param_grid = {
    'n_estimators': [100, 200, 300],
    'max_depth': [3, 5, 7],
    'learning_rate': [0.05, 0.1, 0.2],
    'min_child_weight': [1, 3]
}
grid_search = GridSearchCV(model, param_grid, cv=5, scoring='accuracy', n_jobs=-1)
grid_search.fit(X_train, y_train)

# Best model
best_model = grid_search.best_estimator_
print("Best parameters:", grid_search.best_params_)
print("Best cross-validation accuracy:", grid_search.best_score_)

# Evaluate on test set
accuracy = best_model.score(X_test, y_test)
print(f"Test accuracy: {accuracy:.2f}")

# Cross-validation score
cv_scores = cross_val_score(best_model, X_resampled, y_resampled, cv=5, scoring='accuracy')
print(f"Cross-validation scores: {cv_scores}")
print(f"Mean CV accuracy: {cv_scores.mean():.2f} (+/- {cv_scores.std() * 2:.2f})")

# Feature importance
print("Feature importances:", dict(zip(features, best_model.feature_importances_)))

# Save model, encoders, and scaler
joblib.dump(best_model, "models/priority_model.pkl")
joblib.dump(le_dict, "models/label_encoders.pkl")
joblib.dump(le_y, "models/target_encoder.pkl")
joblib.dump(scaler, "models/scaler.pkl")