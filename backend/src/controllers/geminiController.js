let _ai = null;

async function getAI() {
  if (_ai) return _ai;
  // @google/genai is ESM; use dynamic import from CommonJS.
  const mod = await import("@google/genai");
  const { GoogleGenAI } = mod;
  _ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });
  return _ai;
}

function requireGeminiKey() {
  const key = process.env.GEMINI_API_KEY;
  if (!key) {
    const err = new Error("Missing GEMINI_API_KEY on backend");
    err.statusCode = 500;
    throw err;
  }
  return key;
}

function prescriptionPrompt() {
  return `
You are a medical prescription understanding assistant.

STRICT RULES:
- First, determine if the provided image is a medical prescription.
- If it is NOT a prescription, return ONLY this JSON:
  {"error": "The provided image does not appear to be a medical prescription. Please upload a clear photo of a prescription."}
- If it IS a prescription:
  - Extract ONLY what is clearly present.
  - DO NOT invent or guess missing information.
  - If something is missing, write "Not mentioned".
  - DO NOT add medical advice.
  - Output MUST be in VALID JSON format ONLY.
  - DO NOT wrap the JSON in markdown code blocks like \`\`\`json ... \`\`\`.

OUTPUT JSON FORMAT FOR VALID PRESCRIPTION (FOLLOW EXACTLY):
{
  "doctor": "Doctor Name or Not mentioned",
  "hospital": "Hospital Name or Not mentioned",
  "license": "License No or Not mentioned",
  "patient": "Name or Not mentioned",
  "age": "Age or Not mentioned",
  "gender": "Gender or Not mentioned",
  "date": "Date or Not mentioned",
  "medicines": [
    {
      "name": "Medicine name",
      "dosage": "Dosage",
      "frequency": "Frequency",
      "instructions": "Instructions"
    }
  ],
  "notes": "Notes or Not mentioned"
}
`.trim();
}

// POST /api/gemini/prescription
async function analyzePrescriptionFromImage(req, res) {
  try {
    requireGeminiKey();

    if (!req.file || !req.file.buffer) {
      return res.status(400).json({ error: "Missing image file (field name: image)" });
    }

    const mimeType = req.file.mimetype || "image/jpeg";
    const base64 = req.file.buffer.toString("base64");

    const ai = await getAI();
    const model = process.env.GEMINI_MODEL || "gemini-flash-latest";

    const response = await ai.models.generateContent({
      model,
      contents: [
        {
          role: "user",
          parts: [
            { text: prescriptionPrompt() },
            { inlineData: { mimeType, data: base64 } },
          ],
        },
      ],
      config: { temperature: 0.2 },
    });

    return res.json({ text: response.text || "" });
  } catch (err) {
    const code = err.statusCode || 500;
    // Surface upstream error body when available (helps debugging on Flutter).
    const details =
      err?.response?.data ||
      err?.error ||
      undefined;

    const msg = err?.message || "Internal error";
    return res.status(code).json({ error: msg, details });
  }
}

// GET /api/gemini/models
async function listModels(_req, res) {
  try {
    requireGeminiKey();
    const ai = await getAI();

    const pager = await ai.models.list();
    const models = [];
    for await (const m of pager) {
      models.push({
        name: m.name,
        supportedGenerationMethods: m.supportedGenerationMethods,
      });
      // Keep response bounded; frontend only needs a list, not thousands.
      if (models.length >= 200) break;
    }

    return res.json({ models });
  } catch (err) {
    const code = err.statusCode || 500;
    const details =
      err?.response?.data ||
      err?.error ||
      undefined;
    return res.status(code).json({ error: err.message || "Internal error", details });
  }
}

module.exports = { analyzePrescriptionFromImage, listModels };

