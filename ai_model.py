import numpy as np
from sklearn.ensemble import RandomForestClassifier

# ---------------------------
# Training Data
# ---------------------------
X = np.array([
    [1, 0],
    [0, 0],
    [1, 1],
    [0, 1]
])

y = np.array([0, 1, 2, 2])

model = RandomForestClassifier(n_estimators=10, random_state=42)
model.fit(X, y)

# ---------------------------
# Read Input Files SAFELY
# ---------------------------
data = []
names = []

try:
    with open("data.txt") as f:
        for line in f:
            data.append(list(map(int, line.split())))
except:
    pass

try:
    with open("names.txt") as f:
        for line in f:
            names.append(line.strip())
except:
    pass

# ---------------------------
# Write to report
# ---------------------------
with open("report.txt", "a") as report:

    report.write("\n--- AI MODEL OUTPUT ---\n")

    # 🔥 Handle empty case
    if len(data) == 0:
        report.write("No data available for AI analysis.\n")
    else:
        data = np.array(data)
        pred = model.predict(data)

        total_score = 0

        for i in range(len(pred)):
            name = names[i] if i < len(names) else f"var{i+1}"

            if pred[i] == 0:
                label = "GOOD"
                score = 0
            elif pred[i] == 1:
                label = "WARNING (Unused)"
                score = 3
            else:
                label = "CRITICAL (Duplicate)"
                score = 5

            total_score += score
            report.write(f"{name}: {label} | Score: {score}\n")

        # ---------------------------
        # Better Quality Score
        # ---------------------------
        max_score = len(pred) * 5
        quality = max(60, 100 - int((total_score / max_score) * 100))

        report.write("\n--- AI Code Quality ---\n")
        report.write(f"Total Risk Score: {total_score}\n")
        report.write(f"Overall Quality: {quality}/100\n")

        # ---------------------------
        # Pattern Insights
        # ---------------------------
        report.write("\n--- AI Insights ---\n")

        unused = sum(1 for d in data if d[0] == 0)
        duplicate = sum(1 for d in data if d[1] == 1)

        if unused > 0:
            report.write("Unused variables detected → memory inefficiency.\n")

        if duplicate > 0:
            report.write("Duplicate declarations detected → redundancy.\n")

        if unused == 0 and duplicate == 0:
            report.write("Code is well optimized.\n")