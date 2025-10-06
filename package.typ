#let renderMode = state("renderMode")
#let questionCounter = state("questions")

#let numberSection = numbering.with("1a.")

#let section(name, inner) = context {
  questionCounter.update(tail => (1, ..tail));
  let counter = questionCounter.get();
  let depth = counter.len() + 1;
  let (_, ..sectionPath) = counter;
  heading(depth: depth, [#(numberSection(..counter)) #name]);
  inner;  questionCounter.update(((_, parent, ..tail)) => (parent + 1, ..tail));
  line(length: 100% + 2em, start: (-1em, 0pt), stroke: gray);
};

#let basicQuestion(question, answer) = context {
  let item = if renderMode.get() == "questions" {
    question
  } else if renderMode.get() == "answers" {
    // TODO: page number references back to questions
    answer
  } else {
    return [unknown render mode];
  };
  
  let num = numberSection(..questionCounter.get().rev());
  questionCounter.update(((head, ..tail)) => (head + 1, ..tail));

  grid(
    columns: (2em, auto),
    inset: .5em,
    grid.cell(align: right, num),
    item
  );
};

#let renderWithMode(inner, mode) = {
  renderMode.update(mode);
  questionCounter.update((1,));
  context inner
};

// TODO: render an index page with page numbers for easy printing?
#let render(inner) = {
  heading[Questions];
  renderWithMode(inner, "questions");
  pagebreak();
  heading[Answer Key];
  renderWithMode(inner, "answers");
};

#let writtenResponse(question, answer, space: 10em) = {
  let question = box(height: space, question);
  basicQuestion(question, answer);
};

#let blank(inner) = context {
  if renderMode.get() == "questions" {
    box(stroke: (bottom: black), outset: 2pt, hide(inner))
  } else if renderMode.get() == "answers" {
    underline(emph(inner))
  } else {
    [unknown render mode]
  }
};

#let fillBlanks(inner) = {
  // question/answer functionality is handled by blank()
  basicQuestion(inner, inner)
};
