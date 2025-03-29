out = [];

for (i = 0; i < 256; i++)
{
   x = Math.sin((2 * Math.PI * i) / 256) + 1;
   x = x / 2;
   x = Math.floor(x * 28)
   out.push(x)
}

define = "";

for (i = 0; i < 256; i+=16)
{
    define += ".db " + out.slice(i, i + 16).join(", ") + "\n"
}

console.log(define)