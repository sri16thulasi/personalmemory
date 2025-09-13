from flask import Flask, request, jsonify
import joblib
import pandas as pd
from datetime import datetime

app = Flask(__name__)

# Load model and encoders
model = joblib.load("models/priority_model.pkl")
le_dict = joblib.load("models/label_encoders.pkl")
le_y = joblib.load("models/target_encoder.pkl")
scaler = joblib.load("models/scaler.pkl")

@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.get_json()
        course = data.get('course', 'Not Course Related')
        task_type = data.get('task_type', 'Other')
        time_taken = data.get('time_taken', '1 hour')
        year = data.get('year', '3rd year')
        due_date = data.get('due_date', '2025-05-01')

        # Convert due date to Excel serial
        due_date = datetime.strptime(due_date, '%Y-%m-%d')
        today_serial = (datetime(2025, 5, 1) - datetime(1899, 12, 30)).days
        due_serial = (due_date - datetime(1899, 12, 30)).days
        days_until_due = due_serial - today_serial

        # Prepare input
        input_data = pd.DataFrame({
            "2.Which course is this task for?": [course],
            "4.What type of task is it?": [task_type],
            "5.How much time does this task take?": [time_taken],
            "6.Which year are you studying in?": [year],
            "days_until_due": [days_until_due]
        })

        # Encode categorical features
        for col in input_data.columns[:-1]:
            le = le_dict[col]
            try:
                input_data[col] = le.transform(input_data[col].astype(str))
            except ValueError:
                input_data[col] = le.transform(['Not Course Related' if 'course' in col else '3rd year' if 'year' in col else 'Other'])

        # Add interaction features
        input_data["course_task_interaction"] = input_data["2.Which course is this task for?"] * input_data["4.What type of task is it?"]
        input_data["year_task_interaction"] = input_data["6.Which year are you studying in?"] * input_data["4.What type of task is it?"]

        # Scale days_until_due
        input_data["days_until_due"] = scaler.transform(input_data[["days_until_due"]])

        # Predict
        prediction = model.predict(input_data)
        priority = le_y.inverse_transform(prediction)[0]

        return jsonify({"priority": priority})
    except Exception as e:
        return jsonify({"error": str(e)}), 400

if __name__ == '__main__':
    app.run(debug=True)