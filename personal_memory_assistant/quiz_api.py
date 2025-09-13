from flask import Flask, request, jsonify
import random

app = Flask(__name__)

# Sample syllabus-based question templates (mock for now)
question_templates = {
    "CS8491": {  # Data Structures
        "Unit-1": [
            {
                "question": "What is the time complexity of inserting an element in an array?",
                "options": ["O(1)", "O(n)", "O(n log n)", "O(n^2)"],
                "correctAnswer": 1,
                "explanation": "Array-la element insert pannum pothu, shift pannanum, so O(n) time aagum."
            },
            {
                "question": "What is the purpose of a queue in process scheduling?",
                "options": ["Store processes", "Sort processes", "Delete processes", "Merge processes"],
                "correctAnswer": 0,
                "explanation": "Queue processes-a order-la store pannum, like CPU scheduling-la ready queue."
            }
        ],
        "Common": [
            {
                "question": "What is a linked list in Data Structures?",
                "options": ["A linear data structure", "A tree structure", "A graph", "A stack"],
                "correctAnswer": 0,
                "explanation": "Linked list linear-a data store pannum, each node data and next node pointer hold pannum."
            }
        ]
    }
}

@app.route('/generate_quiz', methods=['POST'])
def generate_quiz():
    data = request.json
    course_code = data.get('courseCode', 'CS8491')
    unit_type = data.get('unitType', 'Common')
    language = data.get('language', 'English')

    # Get questions from templates or mock
    questions = question_templates.get(course_code, {}).get(unit_type, [])
    if not questions:
        questions = [
            {
                "question": f"Sample question for {data['courseName']}?",
                "options": ["Option 1", "Option 2", "Option 3", "Option 4"],
                "correctAnswer": 0,
                "explanation": language == 'Tanglish'
                    and f"Ithu {data['courseName']} la basic concept irukku."
                    or f"This is a basic concept in {data['courseName']}."
            } for _ in range(10)
        ]
    else:
        # Shuffle and select 10 questions
        random.shuffle(questions)
        questions = questions[:10]
        if language == 'Tanglish':
            for q in questions:
                q['explanation'] = q['explanation'].replace('is', 'irukku').replace('are', 'irukku')

    return jsonify(questions)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)