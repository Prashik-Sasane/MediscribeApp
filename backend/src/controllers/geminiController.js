const axios = require("axios");

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
    const apiKey = requireGeminiKey();

    if (!req.file || !req.file.buffer) {
      return res.status(400).json({ error: "Missing image file (field name: image)" });
    }

    const mimeType = req.file.mimetype || "image/jpeg";
    const base64 = req.file.buffer.toString("base64");

    // Use v1beta for broad compatibility with Gemini models.
    const model = process.env.GEMINI_MODEL || "gemini-1.5-flash";
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;

    const body = {
      contents: [
        {
          parts: [
            { text: prescriptionPrompt() },
            { inlineData: { mimeType, data: base64 } },
          ],
        },
      ],
      generationConfig: {
        temperature: 0.2,
      },
    };

    const resp = await axios.post(url, body, {
      headers: { "Content-Type": "application/json" },
      timeout: 45000,
      validateStatus: () => true,
    });

    if (resp.status < 200 || resp.status >= 300) {
      return res.status(resp.status).json({
        error: "Gemini request failed",
        status: resp.status,
        details: resp.data,
      });
    }

    const text =
      resp.data?.candidates?.[0]?.content?.parts?.[0]?.text ??
      resp.data?.candidates?.[0]?.content?.parts?.[1]?.text ??
      "";

    return res.json({ text });
  } catch (err) {
    const code = err.statusCode || 500;
    return res.status(code).json({ error: err.message || "Internal error" });
  }
}

// GET /api/gemini/models
async function listModels(_req, res) {
  try {
    const apiKey = requireGeminiKey();
    const url = `https://generativelanguage.googleapis.com/v1beta/models?key=${apiKey}`;

    const resp = await axios.get(url, {
      timeout: 20000,
      validateStatus: () => true,
    });

    if (resp.status < 200 || resp.status >= 300) {
      return res.status(resp.status).json({
        error: "ListModels failed",
        status: resp.status,
        details: resp.data,
      });
    }

    const models = (resp.data?.models || []).map((m) => ({
      name: m.name,
      supportedGenerationMethods: m.supportedGenerationMethods,
    }));
    return res.json({ models });
  } catch (err) {
    const code = err.statusCode || 500;
    return res.status(code).json({ error: err.message || "Internal error" });
  }
}

module.exports = { analyzePrescriptionFromImage, listModels };

