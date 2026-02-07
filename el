<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>מתרגם כתוביות AI</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-zinc-950 text-zinc-200 font-sans min-h-screen flex flex-col items-center p-6">

    <div class="w-full max-w-sm bg-zinc-900 border border-zinc-800 rounded-2xl p-6 shadow-xl mt-10">
        <h1 class="text-2xl font-black text-red-600 text-center mb-2">SUB-AI</h1>
        <p class="text-zinc-500 text-center text-xs mb-8">תרגום מהיר ישירות מהנייד</p>

        <div class="mb-5">
            <label class="block text-xs mb-1 mr-1 text-zinc-400">OpenAI API Key</label>
            <input type="password" id="apiKey" placeholder="הדבק מפתח כאן..." 
                class="w-full bg-zinc-800 border-none rounded-lg p-3 text-sm focus:ring-2 focus:ring-red-600 outline-none">
        </div>

        <div class="mb-8">
            <label class="flex flex-col items-center justify-center w-full h-32 border-2 border-dashed border-zinc-700 rounded-xl cursor-pointer hover:bg-zinc-800 transition">
                <div class="flex flex-col items-center justify-center pt-5 pb-6">
                    <p id="fileName" class="text-sm text-zinc-400">לחץ לבחירת קובץ SRT</p>
                </div>
                <input type="file" id="fileInput" accept=".srt" class="hidden" onchange="showName()">
            </label>
        </div>

        <button onclick="process()" id="mainBtn" class="w-full bg-red-600 hover:bg-red-700 text-white font-bold py-4 rounded-xl shadow-lg transition duration-300">
            התחל תרגום עכשיו
        </button>

        <div id="statusBox" class="hidden mt-6 p-4 bg-zinc-800 rounded-lg border border-zinc-700">
            <div id="loader" class="text-red-500 text-xs font-bold animate-pulse mb-1">מתרגם... נא לא לסגור</div>
            <div class="w-full bg-zinc-700 h-1.5 rounded-full overflow-hidden">
                <div id="bar" class="bg-red-600 h-full w-0 transition-all duration-300"></div>
            </div>
            <div id="percent" class="text-[10px] text-zinc-500 mt-1 text-left">0%</div>
        </div>
    </div>

    <script>
        function showName() {
            const file = document.getElementById('fileInput').files[0];
            if (file) document.getElementById('fileName').innerText = file.name;
        }

        async function process() {
            const key = document.getElementById('apiKey').value;
            const file = document.getElementById('fileInput').files[0];
            const btn = document.getElementById('mainBtn');
            
            if (!key || !file) return alert("חסר מפתח או קובץ!");

            btn.disabled = true;
            btn.innerText = "מעבד...";
            document.getElementById('statusBox').classList.remove('hidden');

            const text = await file.text();
            const lines = text.split('\n');
            let output = [];
            
            // עיבוד שורות
            for (let i = 0; i < lines.length; i++) {
                let line = lines[i].trim();
                
                // תרגום רק אם זו שורת טקסט (לא זמן ולא מספר שורה)
                if (line && isNaN(line) && !line.includes('-->')) {
                    try {
                        const res = await fetch('https://api.openai.com/v1/chat/completions', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${key}` },
                            body: JSON.stringify({
                                model: "gpt-4o-mini",
                                messages: [{role: "system", content: "Translate to Hebrew. Keep it natural movie style."}, {role: "user", content: line}]
                            })
                        });
                        const data = await res.json();
                        output.push(data.choices[0].message.content || line);
                    } catch (e) { output.push(line); }
                } else {
                    output.push(lines[i]);
                }

                // עדכון מד התקדמות (כל 10 שורות)
                if (i % 10 === 0) {
                    let p = Math.round((i / lines.length) * 100);
                    document.getElementById('bar').style.width = p + '%';
                    document.getElementById('percent').innerText = p + '%';
                }
                
                if (i > 2800) break; // הגבלה לבקשתך
            }

            // הורדה
            const blob = new Blob([output.join('\n')], {type: 'text/plain'});
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = "Hebrew_" + file.name;
            a.click();

            btn.disabled = false;
            btn.innerText = "הסתיים! הורד שוב";
            document.getElementById('loader').innerText = "✅ תרגום הושלם";
        }
    </script>
</body>
</html>
