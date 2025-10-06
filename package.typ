#import "@preview/suiji:0.4.0"

#let renderMode = state("renderMode")
#let questionCounter = state("questions")
#let rngSeed = state("rngSeed")

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

  rngSeed.update(num => num + 1);

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
  rngSeed.update(1);
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

#let selectionBox(contents) = [
  #box(inset: .4em, stroke: black, baseline: .1em)
  #h(.5em)
  #contents \
]

#let multipleChoice(prompt, correct, incorrect) = context {
  let rawChoices = ((true, correct),) + incorrect.map(choice => (false, choice));

  let rng = suiji.gen-rng-f(rngSeed.get());
  let (_rng, shuffled) = suiji.shuffle-f(rng, rawChoices);

  let choices = shuffled.enumerate().map(((idx, (isCorrect, choice))) => (numbering("A", idx + 1), isCorrect, choice));

  let questionChoices = choices.map(((number, _, choice)) => selectionBox[
    #number. #choice
  ])
  .join();

  let question = [ #prompt \ #questionChoices ];

  let (answerNum, _, answerChoice) = choices.find(((_, isCorrect, _)) => isCorrect);

  let answer = [ #answerNum: #answerChoice ];

  basicQuestion(question, answer);
}

#let trueOrFalse(prompt, isTrue) = {
  let question = [
    #prompt \
    #selectionBox([True])
    #selectionBox([False])
  ]

  let answer = if isTrue {
    [True]
  } else {
    [False]
  };

  basicQuestion(question, answer)
}
