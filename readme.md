

<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>My Slide Deck</title>
    <link rel="stylesheet" href="https://unpkg.com/reveal.js/dist/reveal.css" />
    <link rel="stylesheet" href="https://unpkg.com/reveal.js/dist/theme/white.css" />
  </head>
  <body>
    <div class="reveal">
      <div class="slides">

        <!-- Markdown slide deck -->
        <section data-markdown>
          <textarea data-template>

## Slide 1

Welcome to my **Markdown-powered** presentation.

Click *Next* (or use →) to continue.

---

## Slide 2

Here’s a list:

- Item A  
- Item B  
- Item C

---

## Slide 3

You can even do **links**:

[OpenAI](https://openai.com)

---

## Slide 4

Thank you! 🎉

          </textarea>
        </section>

      </div>
    </div>

    <script src="https://unpkg.com/reveal.js/dist/reveal.js"></script>
    <script src="https://unpkg.com/reveal.js/plugin/markdown/marked.js"></script>
    <script src="https://unpkg.com/reveal.js/plugin/markdown/markdown.js"></script>
    <script>
      Reveal.initialize({
        plugins: [RevealMarkdown],
        controls: true,
        progress: true,
        slideNumber: true
      });
    </script>
  </body>
</html>
