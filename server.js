const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const OpenAI = require("openai");

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// ✅ Check for OpenAI API key
if (!process.env.OPENAI_API_KEY) {
  console.error("❌ OPENAI_API_KEY missing in environment variables.");
  process.exit(1);
}

// ✅ Initialize OpenAI
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// ✅ System prompt for SkillerBot
const skillerbotPrompt = `
You are SkillerBot, a motivational and tactical soccer coach for the SoccerSkiller app.
Only answer questions about soccer drills, training, fitness, endurance, or motivation.
If a user asks about anything else (like jokes, school, or food), say:
"Let’s keep it on the field! ⚽💪"
Never invent drills. Be short, clear, and supportive. Use emojis like ⚽🔥✅💪.
`;

// ⚽ General chat endpoint
app.post("/skillerbot", async (req, res) => {
  const { message } = req.body;

  if (!message) {
    return res.status(400).json({ error: "Message is required" });
  }

  console.log("📨 Received /skillerbot message:", message);

  try {
    const completion = await openai.chat.completions.create({
      model: "gpt-3.5-turbo",
      messages: [
        { role: "system", content: skillerbotPrompt },
        { role: "user", content: message },
      ],
    });

    const reply = completion.choices[0]?.message?.content || "⚠️ No response.";
    res.json({ reply });
  } catch (error) {
    console.error("❌ OpenAI API error:", error);
    res.status(500).json({ error: "SkillerBot failed to respond." });
  }
});

// ⚽ Drill-specific Q&A endpoint
app.post("/ask-drill", async (req, res) => {
  const { question, drillTitle, drillInstructions } = req.body;

  if (!question || !drillTitle || !drillInstructions) {
    return res.status(400).json({ error: "Missing required fields." });
  }

  console.log("📨 Received /ask-drill:", { question, drillTitle });

  const formattedPrompt = `
You are SkillerBot, a motivational and tactical soccer coach for the SoccerSkiller app.
Only answer questions about soccer drills, training, fitness, endurance, or motivation.
If a user asks about anything else (like jokes, school, or food), say:
"Let’s keep it on the field! ⚽💪"
Never invent drills. Be short, clear, and supportive. Use emojis like ⚽🔥✅💪.

The user is asking a question about the drill "${drillTitle}".
Drill Instructions: ${drillInstructions}
User Question: ${question}
Provide your best answer below:
`;

  try {
    const completion = await openai.chat.completions.create({
      model: "gpt-3.5-turbo",
      messages: [{ role: "system", content: formattedPrompt }],
    });

    const reply = completion.choices[0]?.message?.content || "⚠️ No response.";
    res.json({ reply });
  } catch (error) {
    console.error("❌ Drill AI error:", error);
    res.status(500).json({ error: "Failed to get drill advice from SkillerBot." });
  }
});

// ✅ Health check
app.get("/", (req, res) => {
  res.send("✅ SkillerBot server is running!");
});

// ✅ Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ SkillerBot running on http://localhost:${PORT}`);
});
