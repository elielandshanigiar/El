<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SubTranslate AI</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-black text-white font-sans flex items-center justify-center min-h-screen p-4">
    <div class="w-full max-w-md bg-[#141414] border border-gray-800 p-8 rounded-lg shadow-2xl">
        <h1 class="text-3xl font-bold mb-6 text-center text-[#E50914]">NET-SUB AI</h1>
        <p class="text-gray-400 text-center mb-8 text-sm">תרגום כתוביות חכם מאנגלית לעברית</p>
        
        <div class="space-y-4">
            <input type="password" id="apiKey" placeholder="הכנס OpenAI API Key" 
                class="w-full p-4 bg-[#333] border-none rounded text-white focus:ring-2 focus:ring-[#E50914] outline-none">
            
            <label class="block w-full text-center p-4 bg-transparent border-2 border-dashed border-gray-600 rounded cursor-pointer hover:border-[#E50914]">
                <span id="fileName">בחר קובץ SRT</span>
                <input type="file" id="fileInput" accept=".srt" class="hidden" onchange="updateName()">
            </label>

            <button onclick="startTranslation()" id="btn" 
                class="w-full bg-[#E50914] hover:bg-[#b20710] text-white font-bold py-4 rounded transition duration-200">
                התחל תרגום
            </button>
        </div>

        <div id="status" class="mt-6 text-center text-sm hidden">
            <div class="animate-pulse text-red-500 mb-2">● מעבד נתונים...</div>
            <div id="progress">0%</div>
        </div>
    </div>

    <script>
        function updateName() {
            const input = document.getElementById('fileInput');
            document.getElementById('fileName').innerText = input.files[0].name;
        }

        async function startTranslation() {
            const apiKey = document.getElementById('apiKey').value;
            const fileInput = document.getElementById('fileInput');
            if (!apiKey || !fileInput.files[0]) return alert("מפתח API וקובץ הם חובה!");

            const file = fileInput.files[0];
            const text = await file.text();
            const lines = text.split('\n');
            const status = document.getElementById('status');
            const progress = document.getElementById('progress');
            
            status.classList.remove('hidden');
            let translatedLines = [];

            for (let i = 0; i < Math.min(lines.length, 2800); i++) {
                let line = lines[i];
                // תרגום שורות טקסט בלבד
                if (line.trim() && isNaN(line) && !line.includes('-->')) {
                    try {
                        const res = await fetch('https://api.openai.com/v1/chat/completions', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${apiKey}` },
                            body: JSON.stringify({
                                model: "gpt-4o-mini",
                                messages: [{role: "system", content: "Translate to Hebrew. Modern slang."}, {role: "user", content: line}]
                            })
                        });
                        const data = await res.json();
                        translatedLines.push(data.choices[0].message.content);
                    } catch (e) { translatedLines.push(line); }
                } else {
                    translatedLines.push(line);
                }
                
                if (i % 5 === 0) progress.innerText = `התקדמות: ${Math.round((i/lines.length)*100)}%`;
            }

            const blob = new Blob([translatedLines.join('\n')], {type: 'text/plain'});
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = "Hebrew_" + file.name;
            a.click();
            status.innerText = "✅ הושלם! הקובץ יורד לטלפון";
        }
    </script>
</body>
</html>
