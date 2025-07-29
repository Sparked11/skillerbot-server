const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const OpenAI = require("openai");

dotenv.config();
const app = express();
app.use(cors());
app.use(express.json());

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

const skillerbotPrompt = `
You are SkillerBot, a motivational and tactical soccer coach for the SoccerSkiller app.
Only answer questions about soccer drills, training, fitness, endurance, or motivation.
If a user asks about anything else (like jokes, school, or food), say:
"Let’s keep it on the field! ⚽💪"
Never invent drills. Be short, clear, and supportive. Use emojis like ⚽🔥✅💪.
`;

app.post("/skillerbot", async (req, res) => {
  const userMessage = req.body.message;

  try {
    const completion = await openai.chat.completions.create({
      model: "gpt-3.5-turbo",
      messages: [
        { role: "system", content: skillerbotPrompt },
        { role: "user", content: userMessage }
      ]
    });

    res.json({ reply: completion.choices[0].message.content });
  } catch (err) {
    console.error("❌ Error:", err.message);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ SkillerBot server is running on http://localhost:${PORT}`);
});

app.get('/', (req, res) => {
  res.send('✅ SkillerBot server is running!');
});
