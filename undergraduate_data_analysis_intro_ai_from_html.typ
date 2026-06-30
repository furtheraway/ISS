#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

#set table(
  inset: 6pt,
  stroke: none
)

#show figure.where(
  kind: table
): set figure.caption(position: top)

#show figure.where(
  kind: image
): set figure.caption(position: bottom)

#let content-to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(content-to-string).join("")
  } else if content.has("body") {
    content-to-string(content.body)
  } else if content == [ ] {
    " "
  }
}
#let conf(
  title: none,
  subtitle: none,
  authors: (),
  keywords: (),
  date: none,
  abstract-title: none,
  abstract: none,
  thanks: none,
  cols: 1,
  margin: (x: 1.25in, y: 1.25in),
  paper: "us-letter",
  lang: "en",
  region: "US",
  font: none,
  fontsize: 11pt,
  mathfont: none,
  codefont: none,
  linestretch: 1,
  sectionnumbering: none,
  linkcolor: none,
  citecolor: none,
  filecolor: none,
  pagenumbering: "1",
  doc,
) = {
  set document(
    title: title,
    keywords: keywords,
  )
  set document(
      author: authors.map(author => content-to-string(author.name)).join(", ", last: " & "),
  ) if authors != none and authors != ()
  set page(
    paper: paper,
    margin: margin,
    numbering: pagenumbering,
    columns: cols
  )

  set par(
    justify: true,
    leading: linestretch * 0.65em
  )
  set text(lang: lang,
           region: region,
           size: fontsize)

  set text(font: font) if font != none
  show math.equation: set text(font: mathfont) if mathfont != none
  show raw: set text(font: codefont) if codefont != none

  set heading(numbering: sectionnumbering)

  show link: set text(fill: rgb(content-to-string(linkcolor))) if linkcolor != none
  show ref: set text(fill: rgb(content-to-string(citecolor))) if citecolor != none
  show link: this => {
    if filecolor != none and type(this.dest) == label {
      text(this, fill: rgb(content-to-string(filecolor)))
    } else {
      text(this)
    }
  }

  block(below: 1em, width: 100%)[
    #if title != none {
      align(center, block[
          #text(weight: "bold", size: 1.5em)[#title #if thanks != none {
              footnote(thanks, numbering: "*")
              counter(footnote).update(n => n - 1)
            }]
          #(
            if subtitle != none {
              parbreak()
              text(weight: "bold", size: 1.25em)[#subtitle]
            }
           )])
    }

    #if authors != none and authors != [] {
      let count = authors.len()
      let ncols = calc.min(count, 3)
      grid(
        columns: (1fr,) * ncols,
        row-gutter: 1.5em,
        ..authors.map(author => align(center)[
          #author.name \
          #author.affiliation \
          #author.email
        ])
      )
    }

    #if date != none {
      align(center)[#block(inset: 1em)[
          #date
        ]]
    }

    #if abstract != none {
      block(inset: 2em)[
        #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
      ]
    }
  ]

  doc
}
#show: doc => conf(
  title: [Undergraduate Introduction to Data Analysis],
  authors: (
    ( name: [Teaching Document],
      affiliation: "",
      email: "" ),
    ),
  lang: "en",
  abstract-title: [Abstract],
  pagenumbering: "1",
  cols: 1,
  doc,
)


#block[
#block[
#block[
= Undergraduate Introduction to Data Analysis
<undergraduate-introduction-to-data-analysis>
Probability, Statistics, Hypothesis Testing, Significance Testing, and
Simple Regression with Python

]
#block[
#block[
#block[
Author
]
#block[
Teaching Document

]
]
]
] <title-block-header>
== 1 How to use this document
<how-to-use-this-document>
This document introduces undergraduate data analysis from the
foundations of probability and #strong[statistics]. It uses Python to
make the ideas concrete through simulation, #strong[visualization], and
analysis.

By the end, students should be able to:

#block[
#set enum(numbering: "1.", start: 1)
+ Explain #strong[random variables], #strong[probability distributions],
  expectation, variance, and sampling variability.
+ Distinguish descriptive #strong[statistics] from #strong[statistical
  inference].
+ State null and alternative hypotheses and choose an appropriate test
  statistic.
+ Interpret p-values, significance levels, #strong[confidence
  intervals], Type I error, Type II error, and statistical power.
+ Fit, interpret, and diagnose a #strong[simple linear regression]
  model.
+ Explain why statistical significance is not the same as practical
  importance or causal proof.
]

=== 1.1 Python setup
<python-setup>
The examples use common scientific Python packages.

#block[
#block[
#block[
```sourceCode
# If needed, install these in a terminal before rendering this document:
# python -m pip install numpy pandas matplotlib scipy statsmodels

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy import stats
import statsmodels.api as sm

rng = np.random.default_rng(42)
```

] <cb1>
#emph[]
]
] <82aeda81>
Throughout this document, we set a random seed so that simulated
examples are reproducible. In real analysis, reproducibility also means
saving the data source, documenting cleaning choices, and recording
package versions.

#block[
#block[
#block[
```sourceCode
import sys
print("Python:", sys.version.split()[0])
print("NumPy:", np.__version__)
print("pandas:", pd.__version__)
```

] <cb2>
#emph[]
]
#block[
```
Python: 3.14.6
NumPy: 2.5.0
pandas: 3.0.3
```

]
] <d207bac0>
== 2 The logic of data analysis
<the-logic-of-data-analysis>
A useful way to organize introductory data analysis is:

#block[
#block[
#block[
```sourceCode
flowchart LR
  A[Real-world question] --> B[Data-generating process]
  B --> C[Observed sample data]
  C --> D[Descriptive statistics and visualization]
  D --> E[Statistical model]
  E --> F[Inference]
  F --> G[Interpretation and decision]
  G --> H[New questions]
```

] <cb4>
#emph[]
]
#block[
#block[
#figure([#block[
  ```mermaid
  flowchart LR
    A[Real-world question] --> B[Data-generating process]
    B --> C[Observed sample data]
    C --> D[Descriptive statistics and visualization]
    D --> E[Statistical model]
    E --> F[Inference]
    F --> G[Interpretation and decision]
    G --> H[New questions]
  ```

  ]],
  caption: [
  ]
)

]
]
]
The key challenge is that we rarely observe an entire population.
Instead, we observe a sample. Probability helps us reason about what
samples tend to look like when a model is true. #strong[Statistics] uses
observed samples to estimate unknown quantities and assess uncertainty.

== 3 Probability foundations
<probability-foundations>
=== 3.1 Probability as long-run relative frequency and uncertainty
<probability-as-long-run-relative-frequency-and-uncertainty>
Probability measures how likely an event is. For an event \\(A\\),

\\\[ 0 \\le P(A) \\le 1. \\\]

If two events \\(A\\) and \\(B\\) cannot occur together, they are
mutually exclusive, and

\\\[ P(A \\cup B) = P(A) + P(B). \\\]

If two events are independent, knowing that one occurred does not change
the probability of the other:

\\\[ P(A \\cap B) = P(A)P(B). \\\]

In data analysis, probability often describes a #strong[data-generating
process]: the process that could have produced the data we observed.

=== 3.2 Random variables
<random-variables>
A #strong[random variable] is a numerical outcome of a random process.
Examples:

- \\(X = 1\\) if a coin lands heads and \\(X = 0\\) otherwise.
- \\(Y\\) = height of a randomly selected student.
- \\(T\\) = time until a machine fails.

#strong[Random variables] can be discrete or continuous.

A #strong[discrete] #strong[random variable] takes countable values,
such as 0, 1, 2, 3. A #strong[continuous] random variable can take
values along an interval, such as any positive real number.

=== 3.3 Example: simulating coin flips
<example-simulating-coin-flips>
For a fair coin, let \\(X = 1\\) for heads and \\(X = 0\\) for tails.
Then \\(X\\) follows a Bernoulli distribution with probability \\(p =
0.5\\).

#block[
#block[
#block[
```sourceCode
n = 20
coin_flips = rng.binomial(n=1, p=0.5, size=n)
coin_flips
```

] <cb5>
#emph[]
]
#block[
```
array([1, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 1, 1])
```

]
] <7dcf358a>
The sample proportion of heads is:

#block[
#block[
#block[
```sourceCode
coin_flips.mean()
```

] <cb7>
#emph[]
]
#block[
```
np.float64(0.6)
```

]
] <c5004bfb>
With only 20 flips, the sample proportion may not be exactly 0.5. Random
samples vary.

#block[
#block[
#block[
```sourceCode
n_flips = 5_000
flips = rng.binomial(n=1, p=0.5, size=n_flips)
running_mean = np.cumsum(flips) / np.arange(1, n_flips + 1)

plt.figure(figsize=(8, 4.5))
plt.plot(running_mean)
plt.axhline(0.5, linestyle="--", linewidth=1)
plt.xlabel("Number of coin flips")
plt.ylabel("Sample proportion of heads")
plt.title("Law of large numbers in action")
plt.show()
```

] <cb9>
#emph[]
]
#block[
#block[
#figure([#block[
  #box(image(".\\_pandoc_media_undergrad/undergraduate_data_analysis_intro_ai_files/figure-html/fig-coin-convergence-output-1.png", height: 4.3125in, width: 6.91667in))
  ]],
  caption: [
    Figure~1: The sample proportion of heads converges toward the true
    probability as the number of flips increases.
  ]
)

] <fig-coin-convergence>
]
] <cell-fig-coin-convergence>
The law of large numbers says that, under suitable conditions, a sample
average tends to get closer to the population mean as sample size grows.

=== 3.4 Probability distributions
<probability-distributions>
A #strong[probability distribution] tells us the possible values of a
#strong[random variable] and how likely they are.

Common distributions in introductory data analysis include:

#figure(
  align(center)[#table(
    columns: (23%, 30%, 23%, 23%),
    align: (auto,right,auto,auto,),
    table.header([Distribution], table.cell(align: right)[Type], [Typical
      use], [Parameters],),
    table.hline(),
    [Bernoulli], table.cell(align: right)[Discrete], [One yes/no
    outcome], [\\(p\\)],
    [Binomial], table.cell(align: right)[Discrete], [Number of successes
    in \\(n\\) independent yes/no trials], [\\(n, p\\)],
    [Normal], table.cell(align: right)[Continuous], [Approximate model
    for many measurements and averages], [\\(\\mu, \\sigma\\)],
    [Student's
    \\(t\\)], table.cell(align: right)[Continuous], [Inference for means
    when population variance is unknown], [degrees of freedom],
    [Chi-square], table.cell(align: right)[Continuous], [Inference about
    variances; model comparison], [degrees of freedom],
    [F], table.cell(align: right)[Continuous], [Comparing model fit;
    ANOVA; regression], [degrees of freedom],
  )]
  , kind: table
  )

=== 3.5 Expectation and variance
<expectation-and-variance>
The expected value of a #strong[random variable] is its
probability-weighted average. For a discrete random variable,

\\\[ E\[X\] = \\sum\_x xP(X=x). \\\]

Variance measures spread around the expected value:

\\\[ \\operatorname{Var}(X) = E\[(X - E\[X\])^2\]. \\\]

The standard deviation is the square root of the variance:

\\\[ \\operatorname{SD}(X) = \\sqrt{\\operatorname{Var}(X)}. \\\]

For a Bernoulli #strong[random variable] \\(X \\sim
\\operatorname{Bernoulli}(p)\\),

\\\[ E\[X\] = p, \\qquad \\operatorname{Var}(X)=p(1-p). \\\]

=== 3.6 Visualizing distributions
<visualizing-distributions>
#block[
#block[
#block[
```sourceCode
x = np.linspace(-5, 5, 400)
plt.figure(figsize=(8, 4.5))
for sigma in [0.5, 1, 2]:
    y = stats.norm.pdf(x, loc=0, scale=sigma)
    plt.plot(x, y, label=f"$\\sigma={sigma}$")
plt.xlabel("x")
plt.ylabel("Density")
plt.title("Normal distributions")
plt.legend()
plt.show()
```

] <cb10>
#emph[]
]
#block[
#block[
#figure([#block[
  #box(image(".\\_pandoc_media_undergrad/undergraduate_data_analysis_intro_ai_files/figure-html/fig-normal-distributions-output-1.png", height: 4.30208in, width: 6.91667in))
  ]],
  caption: [
    Figure~2: Normal distributions with the same mean but different
    standard deviations. Larger standard deviation means more spread.
  ]
)

] <fig-normal-distributions>
]
] <cell-fig-normal-distributions>
For continuous #strong[variables], the curve is a density, not a direct
probability. Probabilities correspond to areas under the curve.

#block[
#block[
#block[
```sourceCode
# Probability that a standard normal variable is less than 1.96
stats.norm.cdf(1.96)
```

] <cb11>
#emph[]
]
#block[
```
np.float64(0.9750021048517795)
```

]
] <3d3cf459>
For a standard normal variable, about 95% of the distribution lies
between -1.96 and 1.96.

#block[
#block[
#block[
```sourceCode
stats.norm.cdf(1.96) - stats.norm.cdf(-1.96)
```

] <cb13>
#emph[]
]
#block[
```
np.float64(0.950004209703559)
```

]
] <9479c44d>
== 4 From populations to samples
<from-populations-to-samples>
=== 4.1 Population, sample, parameter, statistic
<population-sample-parameter-statistic>
A #strong[population] is the full group or process we want to
understand. A #strong[sample] is the data we observe.

A #strong[parameter] is a numerical feature of the population, such as
the population mean \\(\\mu\\). A #strong[statistic] is a numerical
feature computed from a sample, such as the sample mean \\(\\bar{x}\\).

#figure(
  align(center)[#table(
    columns: 3,
    align: (auto,right,right,),
    table.header([Concept], table.cell(align: right)[Population], table.cell(align: right)[Sample],),
    table.hline(),
    [Mean], table.cell(align: right)[\\(\\mu\\)], table.cell(align: right)[\\(\\bar{x}\\)],
    [Variance], table.cell(align: right)[\\(\\sigma^2\\)], table.cell(align: right)[\\(s^2\\)],
    [Standard
    deviation], table.cell(align: right)[\\(\\sigma\\)], table.cell(align: right)[\\(s\\)],
    [Proportion], table.cell(align: right)[\\(p\\)], table.cell(align: right)[\\(\\hat{p}\\)],
    [Regression
    slope], table.cell(align: right)[\\(\\beta\_1\\)], table.cell(align: right)[\\(\\hat{\\beta}\_1\\)],
  )]
  , kind: table
  )

#strong[Statistical inference] asks: what can we say about the
population using the sample?

=== 4.2 Sampling variability
<sampling-variability>
Even when the population does not change, different random samples
produce different #strong[statistics].

#block[
#block[
#block[
```sourceCode
population_mean = 100
population_sd = 15
sample_size = 25
n_samples = 1_000

sample_means = np.array([
    rng.normal(population_mean, population_sd, size=sample_size).mean()
    for _ in range(n_samples)
])

plt.figure(figsize=(8, 4.5))
plt.hist(sample_means, bins=30, edgecolor="black")
plt.axvline(population_mean, linestyle="--", linewidth=1)
plt.xlabel("Sample mean")
plt.ylabel("Frequency")
plt.title("Sampling distribution of the sample mean")
plt.show()
```

] <cb15>
#emph[]
]
#block[
#block[
#figure([#block[
  #box(image(".\\_pandoc_media_undergrad/undergraduate_data_analysis_intro_ai_files/figure-html/fig-sampling-variability-output-1.png", height: 4.3125in, width: 6.86458in))
  ]],
  caption: [
    Figure~3: Different samples from the same population produce
    different sample means.
  ]
)

] <fig-sampling-variability>
]
] <cell-fig-sampling-variability>
The distribution of a statistic over repeated samples is called a
#strong[sampling distribution].

=== 4.3 Standard error
<standard-error>
The standard deviation of a sampling distribution is called a
#strong[standard error].

For the sample mean,

\\\[ SE(\\bar{X}) = \\frac{\\sigma}{\\sqrt{n}}. \\\]

Because \\(\\sigma\\) is usually unknown, we estimate it with the sample
standard deviation \\(s\\):

\\\[ \\widehat{SE}(\\bar{X}) = \\frac{s}{\\sqrt{n}}. \\\]

#block[
#block[
#block[
```sourceCode
observed_sample = rng.normal(population_mean, population_sd, size=sample_size)
xbar = observed_sample.mean()
s = observed_sample.std(ddof=1)
se = s / np.sqrt(sample_size)

pd.DataFrame({
    "quantity": ["sample mean", "sample standard deviation", "estimated standard error"],
    "value": [xbar, s, se]
})
```

] <cb16>
#emph[]
]
#block[
#block[
#figure(
  align(center)[#table(
    columns: 3,
    align: (auto,auto,auto,),
    table.header([], [quantity], [value],),
    table.hline(),
    [0], [sample mean], [92.023431],
    [1], [sample standard deviation], [15.736199],
    [2], [estimated standard error], [3.147240],
  )]
  , kind: table
  )

]
]
] <7c547314>
=== 4.4 Central limit theorem
<central-limit-theorem>
The central limit theorem says that, under broad conditions, the
sampling distribution of the sample mean becomes approximately normal as
sample size increases, even if the original data are not normal.

#block[
#block[
#block[
```sourceCode
# Exponential data are right-skewed. Their sample means become increasingly normal as n grows.
for n in [2, 5, 30]:
    means = np.array([rng.exponential(scale=1, size=n).mean() for _ in range(5_000)])
    plt.figure(figsize=(7, 4))
    plt.hist(means, bins=40, density=True, edgecolor="black")
    plt.xlabel("Sample mean")
    plt.ylabel("Density")
    plt.title(f"Sampling distribution of the mean, n={n}")
    plt.show()
```

] <cb17>
#emph[]
]
#block[
#figure([#block[
  #block[
  #block[
  #figure([#block[
    #box(image(".\\_pandoc_media_undergrad/undergraduate_data_analysis_intro_ai_files/figure-html/fig-clt-output-1.png", height: 3.92708in, width: 6.14583in))
    ]],
    caption: [
      \(a) The central limit theorem: sample means become more
      normal-shaped as sample size increases.
    ]
  )

  ] <fig-clt-1>
  ]
  #block[
  #block[
  #figure([#block[
    #box(image(".\\_pandoc_media_undergrad/undergraduate_data_analysis_intro_ai_files/figure-html/fig-clt-output-2.png", height: 3.92708in, width: 6.14583in))
    ]],
    caption: [
      \(b)
    ]
  )

  ] <fig-clt-2>
  ]
  #block[
  #block[
  #figure([#block[
    #box(image(".\\_pandoc_media_undergrad/undergraduate_data_analysis_intro_ai_files/figure-html/fig-clt-output-3.png", height: 3.92708in, width: 6.14583in))
    ]],
    caption: [
      \(c)
    ]
  )

  ] <fig-clt-3>
  ]
  ]],
  caption: [
    Figure~4
  ]
)

] <fig-clt>
]
This theorem is one reason normal-based methods are common. It does not
mean all data are normal. It means many averages are approximately
normal when sample sizes are large enough and observations are
sufficiently independent.

== 5 Descriptive statistics and exploratory data analysis
<descriptive-statistics-and-exploratory-data-analysis>
Before formal inference, inspect the data. Descriptive
#strong[statistics] summarize what was observed; they do not
automatically justify conclusions about a broader population.

=== 5.1 A small teaching dataset
<a-small-teaching-dataset>
The following simulated #strong[dataset] represents students in an
introductory course. Each row is one student. The #strong[variables]
are:

- `study_hours`: hours studied for a test.
- `attendance`: proportion of lectures attended.
- `review_session`: whether the student attended an optional review
  session.
- `score`: exam score.

The data are simulated for teaching, not collected from real students.

#block[
#block[
#block[
```sourceCode
n = 120
study_hours = rng.gamma(shape=3, scale=2, size=n)
attendance = np.clip(rng.normal(0.78, 0.14, size=n), 0.3, 1.0)
review_session = rng.binomial(1, p=0.45, size=n)

# Data-generating process for teaching:
# score depends on study hours, attendance, review session, and random noise.
noise = rng.normal(0, 7, size=n)
score = 55 + 2.4 * study_hours + 12 * attendance + 4.5 * review_session + noise
score = np.clip(score, 0, 100)

students = pd.DataFrame({
    "study_hours": study_hours,
    "attendance": attendance,
    "review_session": review_session,
    "score": score
})

students.head()
```

] <cb18>
#emph[]
]
#block[
#block[
#figure(
  align(center)[#table(
    columns: 5,
    align: (auto,auto,auto,auto,auto,),
    table.header([], [study\_hours], [attendance], [review\_session], [score],),
    table.hline(),
    [0], [2.862679], [0.748358], [0], [73.576097],
    [1], [7.130522], [0.733883], [0], [78.855770],
    [2], [2.783708], [0.632852], [1], [73.972079],
    [3], [5.231253], [1.000000], [0], [87.441127],
    [4], [6.372933], [0.932783], [1], [86.235048],
  )]
  , kind: table
  )

]
] <create-teaching-data>
] <cell-create-teaching-data>
=== 5.2 Summaries
<summaries>
#block[
#block[
#block[
```sourceCode
students.describe()
```

] <cb19>
#emph[]
]
#block[
#block[
#figure(
  align(center)[#table(
    columns: 5,
    align: (auto,auto,auto,auto,auto,),
    table.header([], [study\_hours], [attendance], [review\_session], [score],),
    table.hline(),
    [count], [120.000000], [120.000000], [120.000000], [120.000000],
    [mean], [5.576298], [0.785238], [0.425000], [78.287335],
    [std], [3.214783], [0.143691], [0.496416], [9.566944],
    [min], [0.918025], [0.439859], [0.000000], [61.494510],
    [25%], [3.397686], [0.673594], [0.000000], [71.152046],
    [50%], [4.806480], [0.795098], [0.000000], [77.727391],
    [75%], [7.210374], [0.903067], [1.000000], [85.238970],
    [max], [17.384988], [1.000000], [1.000000], [100.000000],
  )]
  , kind: table
  )

]
]
] <dedf5cd6>
#block[
#block[
#block[
```sourceCode
students.groupby("review_session")["score"].agg(["count", "mean", "std"])
```

] <cb20>
#emph[]
]
#block[
#block[
#figure(
  align(center)[#table(
    columns: 4,
    align: (auto,auto,auto,auto,),
    table.header([], [count], [mean], [std],
      [review\_session], [], [], [],),
    table.hline(),
    [0], [69], [75.670367], [7.598096],
    [1], [51], [81.827939], [10.820402],
  )]
  , kind: table
  )

]
]
] <4e75f7a0>
=== 5.3 Visual inspection
<visual-inspection>
#block[
#block[
#block[
```sourceCode
plt.figure(figsize=(8, 4.5))
plt.hist(students["score"], bins=20, edgecolor="black")
plt.xlabel("Exam score")
plt.ylabel("Number of students")
plt.title("Distribution of exam scores")
plt.show()
```

] <cb21>
#emph[]
]
#block[
#block[
#figure([#block[
  #box(image(".\\_pandoc_media_undergrad/undergraduate_data_analysis_intro_ai_files/figure-html/fig-score-histogram-output-1.png", height: 4.30208in, width: 6.875in))
  ]],
  caption: [
    Figure~5: Distribution of exam scores in the teaching dataset.
  ]
)

] <fig-score-histogram>
]
] <cell-fig-score-histogram>
#block[
#block[
#block[
```sourceCode
scores_no = students.loc[students["review_session"] == 0, "score"]
scores_yes = students.loc[students["review_session"] == 1, "score"]

plt.figure(figsize=(7, 4.5))
plt.boxplot([scores_no, scores_yes], tick_labels=["No review", "Review"])
plt.ylabel("Exam score")
plt.title("Scores by review-session attendance")
plt.show()
```

] <cb22>
#emph[]
]
#block[
#block[
#figure([#block[
  #box(image(".\\_pandoc_media_undergrad/undergraduate_data_analysis_intro_ai_files/figure-html/fig-score-by-review-output-1.png", height: 4.11458in, width: 6.1875in))
  ]],
  caption: [
    Figure~6: Exam scores by optional review-session attendance.
  ]
)

] <fig-score-by-review>
]
] <cell-fig-score-by-review>
#block[
#block[
#block[
```sourceCode
plt.figure(figsize=(8, 4.5))
plt.scatter(students["study_hours"], students["score"], alpha=0.75)
plt.xlabel("Study hours")
plt.ylabel("Exam score")
plt.title("Exam score versus study hours")
plt.show()
```

] <cb23>
#emph[]
]
#block[
#block[
#figure([#block[
  #box(image(".\\_pandoc_media_undergrad/undergraduate_data_analysis_intro_ai_files/figure-html/fig-score-vs-study-output-1.png", height: 4.3125in, width: 6.95833in))
  ]],
  caption: [
    Figure~7: Scatterplot of exam score against study hours.
  ]
)

] <fig-score-vs-study>
]
] <cell-fig-score-vs-study>
Exploratory plots help identify patterns, unusual values, and possible
modeling choices. They do not by themselves prove that one variable
causes another.

== 6 Estimation and confidence intervals
<estimation-and-confidence-intervals>
=== 6.1 Point estimates
<point-estimates>
A point estimate is a single-number estimate of an unknown parameter.
Examples:

- \\(\\bar{x}\\) estimates the population mean \\(\\mu\\).
- \\(\\hat{p}\\) estimates the population proportion \\(p\\).
- \\(\\hat{\\beta}\_1\\) estimates the regression slope \\(\\beta\_1\\).

For the average exam score:

#block[
#block[
#block[
```sourceCode
mean_score = students["score"].mean()
mean_score
```

] <cb24>
#emph[]
]
#block[
```
np.float64(78.28733504318683)
```

]
] <c9da965a>
=== 6.2 Confidence intervals
<confidence-intervals>
A #strong[confidence interval] gives a range of plausible parameter
values under a statistical model.

For a mean, when the population standard deviation is unknown, a common
interval is

\\\[ \\bar{x} \\pm t^\*\_{n-1}\\frac{s}{\\sqrt{n}}, \\\]

where \\(t^\*\_{n-1}\\) is a critical value from the Student's \\(t\\)
distribution with \\(n-1\\) degrees of freedom.

#block[
#block[
#block[
```sourceCode
x = students["score"]
n = len(x)
xbar = x.mean()
s = x.std(ddof=1)
se = s / np.sqrt(n)
confidence = 0.95
alpha = 1 - confidence
t_star = stats.t.ppf(1 - alpha / 2, df=n - 1)
ci = (xbar - t_star * se, xbar + t_star * se)

pd.DataFrame({
    "quantity": ["mean", "standard error", "t critical value", "CI lower", "CI upper"],
    "value": [xbar, se, t_star, ci[0], ci[1]]
})
```

] <cb26>
#emph[]
]
#block[
#block[
#figure(
  align(center)[#table(
    columns: 3,
    align: (auto,auto,auto,),
    table.header([], [quantity], [value],),
    table.hline(),
    [0], [mean], [78.287335],
    [1], [standard error], [0.873339],
    [2], [t critical value], [1.980100],
    [3], [CI lower], [76.558037],
    [4], [CI upper], [80.016633],
  )]
  , kind: table
  )

]
]
] <722decc6>
A 95% #strong[confidence interval] does not mean there is a 95%
probability that this particular interval contains the true mean,
assuming a fixed frequentist parameter. Instead, if the same sampling
procedure were repeated many times, about 95% of such intervals would
contain the true parameter.

=== 6.3 Confidence intervals by simulation
<confidence-intervals-by-simulation>
#block[
#block[
#block[
```sourceCode
true_mu = 50
true_sigma = 10
n = 25
n_intervals = 80

intervals = []
contains = []
for i in range(n_intervals):
    sample = rng.normal(true_mu, true_sigma, size=n)
    xbar = sample.mean()
    s = sample.std(ddof=1)
    se = s / np.sqrt(n)
    t_star = stats.t.ppf(0.975, df=n - 1)
    lo = xbar - t_star * se
    hi = xbar + t_star * se
    intervals.append((lo, hi))
    contains.append(lo <= true_mu <= hi)

plt.figure(figsize=(8, 8))
for i, ((lo, hi), ok) in enumerate(zip(intervals, contains)):
    plt.plot([lo, hi], [i, i], linewidth=1)
    plt.plot([(lo + hi) / 2], [i], marker="o", markersize=3)
plt.axvline(true_mu, linestyle="--", linewidth=1)
plt.xlabel("Confidence interval for mean")
plt.ylabel("Simulated sample")
plt.title("Repeated 95% confidence intervals")
plt.show()

sum(contains), n_intervals
```

] <cb27>
#emph[]
]
#block[
#block[
#figure([#block[
  #box(image(".\\_pandoc_media_undergrad/undergraduate_data_analysis_intro_ai_files/figure-html/fig-ci-coverage-output-1.png", height: 7in, width: 6.875in))
  ]],
  caption: [
    Figure~8: Confidence intervals vary from sample to sample. Most 95%
    intervals contain the true mean, but some do not.
  ]
)

] <fig-ci-coverage>
]
] <cell-fig-ci-coverage>
== 7 Hypothesis tests and significance tests
<hypothesis-tests-and-significance-tests>
=== 7.1 Basic idea
<basic-idea>
A #strong[hypothesis] test compares observed data to what we would
expect under a null hypothesis.

A common workflow is:

#block[
#block[
#block[
```sourceCode
flowchart TD
  A[State research question] --> B[Define null hypothesis H0]
  B --> C[Define alternative hypothesis H1 or HA]
  C --> D[Choose test statistic]
  D --> E[Compute observed test statistic]
  E --> F[Compute p-value under H0]
  F --> G[Compare p-value with alpha]
  G --> H[Interpret in context]
```

] <cb28>
#emph[]
]
#block[
#block[
#figure([#block[
  ```mermaid
  flowchart TD
    A[State research question] --> B[Define null hypothesis H0]
    B --> C[Define alternative hypothesis H1 or HA]
    C --> D[Choose test statistic]
    D --> E[Compute observed test statistic]
    E --> F[Compute p-value under H0]
    F --> G[Compare p-value with alpha]
    G --> H[Interpret in context]
  ```

  ]],
  caption: [
  ]
)

]
]
]
The #strong[null hypothesis] \\(H\_0\\) is a baseline claim, often
representing no effect, no difference, or a specific parameter value.
The #strong[alternative hypothesis] \\(H\_A\\) represents the pattern
the researcher is looking for.

Examples:

#figure(
  align(center)[#table(
    columns: (33%, 33%, 33%),
    align: (auto,auto,auto,),
    table.header([Question], [Null hypothesis], [Alternative
      hypothesis],),
    table.hline(),
    [Is the average score different from
    75?], [\\(\\mu=75\\)], [\\(\\mu\\ne75\\)],
    [Is the review group mean
    higher?], [\\(\\mu\_{review}\\le\\mu\_{no\\
    review}\\)], [\\(\\mu\_{review}\>\\mu\_{no\\ review}\\)],
    [Is study time associated with
    score?], [\\(\\beta\_1=0\\)], [\\(\\beta\_1\\ne0\\)],
  )]
  , kind: table
  )

=== 7.2 Hypothesis test vs.~significance test
<hypothesis-test-vs.-significance-test>
The terms are often used interchangeably, but it is useful to separate
two related ideas.

A #strong[significance test] usually focuses on the p-value: how
surprising are the data if the null #strong[hypothesis] were true?

A #strong[hypothesis test] often includes a pre-specified decision rule:
reject \\(H\_0\\) if the p-value is less than a chosen
#strong[significance level] \\(\\alpha\\).

For example, with \\(\\alpha = 0.05\\):

- If \\(p \< 0.05\\), reject \\(H\_0\\).
- If \\(p \\ge 0.05\\), do not reject \\(H\_0\\).

The phrase “do not reject” is important. It does not mean we have proven
the null #strong[hypothesis] true. It means the data did not provide
strong enough evidence against it using the chosen test and
#strong[significance level].

=== 7.3 The p-value
<the-p-value>
A p-value is the probability, assuming the null #strong[hypothesis] is
true, of getting a test statistic as extreme as or more extreme than the
one observed.

A p-value is not:

- The probability that the null #strong[hypothesis] is true.
- The probability that the #strong[alternative hypothesis] is true.
- The probability that the result happened by chance.
- A measure of the size or practical importance of an effect.

=== 7.4 Significance level, Type I error, Type II error, and power
<significance-level-type-i-error-type-ii-error-and-power>
The #strong[significance level] \\(\\alpha\\) is the long-run
probability of rejecting a true null #strong[hypothesis] when the test
assumptions hold. This is called a #strong[Type I error].

A #strong[Type II error] happens when we fail to reject a false null
#strong[hypothesis].

#strong[Power] is the probability of rejecting a false null
#strong[hypothesis]:

\\\[ \\text{Power} = 1 - P(\\text{Type II error}). \\\]

#figure(
  align(center)[#table(
    columns: 3,
    align: (auto,auto,auto,),
    table.header([Reality], [Decision: do not reject
      \\(H\_0\\)], [Decision: reject \\(H\_0\\)],),
    table.hline(),
    [\\(H\_0\\) true], [Correct non-rejection], [Type I error],
    [\\(H\_0\\) false], [Type II error], [Correct rejection],
  )]
  , kind: table
  )

=== 7.5 One-sample t-test
<one-sample-t-test>
Suppose we want to test whether the population mean exam score differs
from 75.

\\\[ H\_0: \\mu = 75 \\\]

\\\[ H\_A: \\mu \\ne 75 \\\]

The one-sample t statistic is

\\\[ t = \\frac{\\bar{x} - \\mu\_0}{s/\\sqrt{n}}. \\\]

#block[
#block[
#block[
```sourceCode
mu0 = 75
x = students["score"]
n = len(x)
xbar = x.mean()
s = x.std(ddof=1)
se = s / np.sqrt(n)
t_stat = (xbar - mu0) / se
p_value = 2 * stats.t.sf(abs(t_stat), df=n - 1)

pd.DataFrame({
    "quantity": ["sample mean", "hypothesized mean", "standard error", "t statistic", "p-value"],
    "value": [xbar, mu0, se, t_stat, p_value]
})
```

] <cb29>
#emph[]
]
#block[
#block[
#figure(
  align(center)[#table(
    columns: 3,
    align: (auto,auto,auto,),
    table.header([], [quantity], [value],),
    table.hline(),
    [0], [sample mean], [78.287335],
    [1], [hypothesized mean], [75.000000],
    [2], [standard error], [0.873339],
    [3], [t statistic], [3.764102],
    [4], [p-value], [0.000261],
  )]
  , kind: table
  )

]
]
] <bfd46297>
The same test can be done with SciPy:

#block[
#block[
#block[
```sourceCode
stats.ttest_1samp(students["score"], popmean=75)
```

] <cb30>
#emph[]
]
#block[
```
TtestResult(statistic=np.float64(3.764101620327317), pvalue=np.float64(0.0002610704768896567), df=np.int64(119))
```

]
] <e369c381>
=== 7.6 Visualizing a two-sided p-value
<visualizing-a-two-sided-p-value>
#block[
#block[
#block[
```sourceCode
x_grid = np.linspace(-4, 4, 500)
df = len(students) - 1
y_grid = stats.t.pdf(x_grid, df=df)

plt.figure(figsize=(8, 4.5))
plt.plot(x_grid, y_grid)
plt.axvline(t_stat, linestyle="--", linewidth=1)
plt.axvline(-abs(t_stat), linestyle="--", linewidth=1)
plt.axvline(abs(t_stat), linestyle="--", linewidth=1)

# Shade tails
left_tail = x_grid <= -abs(t_stat)
right_tail = x_grid >= abs(t_stat)
plt.fill_between(x_grid[left_tail], y_grid[left_tail], alpha=0.3)
plt.fill_between(x_grid[right_tail], y_grid[right_tail], alpha=0.3)

plt.xlabel("t statistic under the null hypothesis")
plt.ylabel("Density")
plt.title("Two-sided p-value for a one-sample t-test")
plt.show()
```

] <cb32>
#emph[]
]
#block[
#block[
#figure([#block[
  #box(image(".\\_pandoc_media_undergrad/undergraduate_data_analysis_intro_ai_files/figure-html/fig-one-sample-pvalue-output-1.png", height: 4.3125in, width: 7.01042in))
  ]],
  caption: [
    Figure~9: A two-sided p-value is the area in both tails at least as
    extreme as the observed test statistic.
  ]
)

] <fig-one-sample-pvalue>
]
] <cell-fig-one-sample-pvalue>
=== 7.7 Interpreting test results
<interpreting-test-results>
A good interpretation includes all of the following:

#block[
#set enum(numbering: "1.", start: 1)
+ The parameter or comparison being tested.
+ The estimate from the data.
+ The p-value or #strong[confidence interval].
+ A conclusion in context.
+ A warning about assumptions or limitations when relevant.
]

Template:

#quote(block: true)[
We tested whether the population mean exam score differs from 75. The
sample mean is computed in the code above. Under a one-sample t-test,
the p-value is computed from the t distribution. At \\(\\alpha=0.05\\),
we reject or do not reject the null depending on whether the p-value is
below 0.05. This result should be interpreted under the assumptions of
independent observations and an approximately valid t-test model.
]

Quarto's inline Python syntax may depend on the rendering engine
configuration. A safer approach in teaching documents is often to
compute values in code chunks and write the conclusion manually.

=== 7.8 Two-sample t-test
<two-sample-t-test>
Now suppose we compare scores for students who attended the optional
review session with those who did not.

Let \\(\\mu\_1\\) be the population mean score for students who attended
the review session, and \\(\\mu\_0\\) the population mean score for
students who did not.

A two-sided test is:

\\\[ H\_0: \\mu\_1 - \\mu\_0 = 0 \\\]

\\\[ H\_A: \\mu\_1 - \\mu\_0 \\ne 0 \\\]

#block[
#block[
#block[
```sourceCode
review = students.loc[students["review_session"] == 1, "score"]
no_review = students.loc[students["review_session"] == 0, "score"]

summary = pd.DataFrame({
    "group": ["No review", "Review"],
    "n": [len(no_review), len(review)],
    "mean": [no_review.mean(), review.mean()],
    "sd": [no_review.std(ddof=1), review.std(ddof=1)]
})
summary
```

] <cb33>
#emph[]
]
#block[
#block[
#figure(
  align(center)[#table(
    columns: 5,
    align: (auto,auto,auto,auto,auto,),
    table.header([], [group], [n], [mean], [sd],),
    table.hline(),
    [0], [No review], [69], [75.670367], [7.598096],
    [1], [Review], [51], [81.827939], [10.820402],
  )]
  , kind: table
  )

]
]
] <560369db>
Welch's t-test does not assume equal population variances.

#block[
#block[
#block[
```sourceCode
stats.ttest_ind(review, no_review, equal_var=False)
```

] <cb34>
#emph[]
]
#block[
```
TtestResult(statistic=np.float64(3.479137071234403), pvalue=np.float64(0.0007966286697875997), df=np.float64(84.80426876919141))
```

]
] <d8140197>
An estimated mean difference is:

#block[
#block[
#block[
```sourceCode
mean_diff = review.mean() - no_review.mean()
mean_diff
```

] <cb36>
#emph[]
]
#block[
```
np.float64(6.157571279001971)
```

]
] <77251e03>
For teaching, compare the p-value with the effect size. A tiny p-value
for a very small effect may not matter in practice, especially with a
large sample. A large p-value can occur when the effect is meaningful
but the sample is too small to estimate it precisely.

=== 7.9 Confidence interval for a two-sample mean difference
<confidence-interval-for-a-two-sample-mean-difference>
#block[
#block[
#block[
```sourceCode
n1, n0 = len(review), len(no_review)
s1, s0 = review.std(ddof=1), no_review.std(ddof=1)
se_diff = np.sqrt(s1**2 / n1 + s0**2 / n0)

# Welch-Satterthwaite degrees of freedom
welch_df = (s1**2/n1 + s0**2/n0)**2 / ((s1**2/n1)**2/(n1-1) + (s0**2/n0)**2/(n0-1))
t_star = stats.t.ppf(0.975, df=welch_df)
ci_diff = (mean_diff - t_star * se_diff, mean_diff + t_star * se_diff)

pd.DataFrame({
    "quantity": ["mean difference", "standard error", "Welch df", "CI lower", "CI upper"],
    "value": [mean_diff, se_diff, welch_df, ci_diff[0], ci_diff[1]]
})
```

] <cb38>
#emph[]
]
#block[
#block[
#figure(
  align(center)[#table(
    columns: 3,
    align: (auto,auto,auto,),
    table.header([], [quantity], [value],),
    table.hline(),
    [0], [mean difference], [6.157571],
    [1], [standard error], [1.769856],
    [2], [Welch df], [84.804269],
    [3], [CI lower], [2.638506],
    [4], [CI upper], [9.676636],
  )]
  , kind: table
  )

]
]
] <7cf0c2c2>
=== 7.10 One-sided tests
<one-sided-tests>
A one-sided alternative tests for a direction.

For example:

\\\[ H\_0: \\mu\_1 - \\mu\_0 \\le 0 \\\]

\\\[ H\_A: \\mu\_1 - \\mu\_0 \> 0 \\\]

Use a one-sided test only when the direction was chosen before seeing
the data and when an effect in the opposite direction would not support
the same conclusion.

#block[
#block[
#block[
```sourceCode
# SciPy supports alternatives in recent versions.
stats.ttest_ind(review, no_review, equal_var=False, alternative="greater")
```

] <cb39>
#emph[]
]
#block[
```
TtestResult(statistic=np.float64(3.479137071234403), pvalue=np.float64(0.00039831433489379985), df=np.float64(84.80426876919141))
```

]
] <234dc9f1>
=== 7.11 Simulation view of a null distribution
<simulation-view-of-a-null-distribution>
A test statistic is compared with a null distribution. We can often
approximate a null distribution by simulation.

For the review-session comparison, the null #strong[hypothesis] says
that group labels do not matter. A permutation test repeatedly shuffles
the labels and recomputes the mean difference.

#block[
#block[
#block[
```sourceCode
observed_diff = review.mean() - no_review.mean()
B = 5_000
permuted_diffs = np.empty(B)

scores = students["score"].to_numpy()
labels = students["review_session"].to_numpy()

for b in range(B):
    shuffled = rng.permutation(labels)
    perm_review = scores[shuffled == 1]
    perm_no_review = scores[shuffled == 0]
    permuted_diffs[b] = perm_review.mean() - perm_no_review.mean()

p_perm = np.mean(np.abs(permuted_diffs) >= abs(observed_diff))

plt.figure(figsize=(8, 4.5))
plt.hist(permuted_diffs, bins=40, edgecolor="black")
plt.axvline(observed_diff, linestyle="--", linewidth=1)
plt.axvline(-abs(observed_diff), linestyle="--", linewidth=1)
plt.axvline(abs(observed_diff), linestyle="--", linewidth=1)
plt.xlabel("Mean difference under shuffled labels")
plt.ylabel("Frequency")
plt.title(f"Permutation test null distribution; p ≈ {p_perm:.3f}")
plt.show()

p_perm
```

] <cb41>
#emph[]
]
#block[
#figure([#block[
  #block[
  #block[
  #figure([#block[
    #box(image(".\\_pandoc_media_undergrad/undergraduate_data_analysis_intro_ai_files/figure-html/fig-permutation-test-output-1.png", height: 4.3125in, width: 6.95833in))
    ]],
    caption: [
      \(a) Permutation null distribution for the difference in mean exam
      score between review and no-review groups.
    ]
  )

  ] <fig-permutation-test-1>
  ]
  #block[
  #figure([#block[
    ```
    np.float64(0.0006)
    ```

    ]],
    caption: [
      \(b)
    ]
  )

  ] <fig-permutation-test-2>
  ]],
  caption: [
    Figure~10
  ]
)

] <fig-permutation-test>
]
Permutation tests are valuable because they show the logic of inference
directly: compare the observed statistic with values that would be
plausible if the null #strong[hypothesis] were true.

=== 7.12 Multiple testing
<multiple-testing>
If we run many tests, some may be significant by chance even when all
null hypotheses are true. With \\(m\\) independent tests and
\\(\\alpha=0.05\\), the expected number of false positives is
\\(0.05m\\).

#block[
#block[
#block[
```sourceCode
m = 1_000
p_values_under_null = rng.uniform(0, 1, size=m)

plt.figure(figsize=(8, 4.5))
plt.hist(p_values_under_null, bins=20, edgecolor="black")
plt.axvline(0.05, linestyle="--", linewidth=1)
plt.xlabel("p-value")
plt.ylabel("Frequency")
plt.title("P-values when all null hypotheses are true")
plt.show()

(p_values_under_null < 0.05).sum()
```

] <cb43>
#emph[]
]
#block[
#figure([#block[
  #block[
  #block[
  #figure([#block[
    #box(image(".\\_pandoc_media_undergrad/undergraduate_data_analysis_intro_ai_files/figure-html/fig-multiple-testing-output-1.png", height: 4.3125in, width: 6.86458in))
    ]],
    caption: [
      \(a) When many null hypotheses are true, some p-values will fall
      below 0.05 by chance.
    ]
  )

  ] <fig-multiple-testing-1>
  ]
  #block[
  #figure([#block[
    ```
    np.int64(52)
    ```

    ]],
    caption: [
      \(b)
    ]
  )

  ] <fig-multiple-testing-2>
  ]],
  caption: [
    Figure~11
  ]
)

] <fig-multiple-testing>
]
Common responses to multiple testing include reducing the number of
tests, pre-specifying hypotheses, reporting all tests, and applying
corrections such as Bonferroni or false discovery rate procedures.

== 8 Simple linear regression
<simple-linear-regression>
=== 8.1 The regression question
<the-regression-question>
Regression models relationships between #strong[variables]. In
#strong[simple linear regression], we model a numerical outcome \\(Y\\)
using one predictor \\(X\\).

The population model is:

\\\[ Y\_i = \\beta\_0 + \\beta\_1X\_i + \\varepsilon\_i. \\\]

Where:

- \\(Y\_i\\) is the outcome for observation \\(i\\).
- \\(X\_i\\) is the predictor for observation \\(i\\).
- \\(\\beta\_0\\) is the intercept.
- \\(\\beta\_1\\) is the slope.
- \\(\\varepsilon\_i\\) is the error term.

The fitted regression line is:

\\\[ \\hat{Y}\_i = \\hat{\\beta}\_0 + \\hat{\\beta}\_1X\_i. \\\]

The residual is:

\\\[ e\_i = Y\_i - \\hat{Y}\_i. \\\]

=== 8.2 Least squares
<least-squares>
Ordinary least squares chooses the intercept and slope that minimize the
sum of squared residuals:

\\\[ \\min\_{b\_0,b\_1}\\sum\_{i=1}^n (y\_i - b\_0 - b\_1x\_i)^2. \\\]

The slope estimate in #strong[simple linear regression] is:

\\\[ \\hat{\\beta}\_1 = \\frac{\\sum\_i
(x\_i-\\bar{x})(y\_i-\\bar{y})}{\\sum\_i (x\_i-\\bar{x})^2}. \\\]

The intercept estimate is:

\\\[ \\hat{\\beta}\_0 = \\bar{y} - \\hat{\\beta}\_1\\bar{x}. \\\]

=== 8.3 Fitting a simple regression manually
<fitting-a-simple-regression-manually>
We model exam score using study hours.

#block[
#block[
#block[
```sourceCode
x = students["study_hours"].to_numpy()
y = students["score"].to_numpy()

xbar = x.mean()
ybar = y.mean()

beta1_hat = np.sum((x - xbar) * (y - ybar)) / np.sum((x - xbar) ** 2)
beta0_hat = ybar - beta1_hat * xbar

beta0_hat, beta1_hat
```

] <cb45>
#emph[]
]
#block[
```
(np.float64(67.88164434164852), np.float64(1.8660571004540298))
```

]
] <0459c856>
Interpretation of the slope: for each additional hour studied, the
fitted model predicts an average change of `beta1_hat` points in exam
score. The units are “score points per study hour.”

=== 8.4 Fitting the same regression with statsmodels
<fitting-the-same-regression-with-statsmodels>
#block[
#block[
#block[
```sourceCode
X = sm.add_constant(students["study_hours"])
model = sm.OLS(students["score"], X).fit()
model.summary()
```

] <cb47>
#emph[]
]
#block[
#figure(
  align(center)[#table(
    columns: 4,
    align: (auto,auto,auto,auto,),
    [Dep. Variable:], [score], [R-squared:], [0.393],
    [Model:], [OLS], [Adj. R-squared:], [0.388],
    [Method:], [Least Squares], [F-statistic:], [76.46],
    [Date:], [Tue, 30 Jun 2026], [Prob (F-statistic):], [1.83e-14],
    [Time:], [02:49:30], [Log-Likelihood:], [-410.80],
    [No. Observations:], [120], [AIC:], [825.6],
    [Df Residuals:], [118], [BIC:], [831.2],
    [Df Model:], [1], [], [],
    [Covariance Type:], [nonrobust], [], [],
  )]
  , caption: [OLS Regression Results]
  , kind: table
  )

#figure(
  align(center)[#table(
    columns: 7,
    align: (auto,auto,auto,auto,auto,auto,auto,),
    [], [coef], [std err], [t], [P\>|t|], [\[0.025], [0.975\]],
    [const], [67.8816], [1.372], [49.470], [0.000], [65.164], [70.599],
    [study\_hours], [1.8661], [0.213], [8.744], [0.000], [1.443], [2.289],
  )]
  , kind: table
  )

#figure(
  align(center)[#table(
    columns: 4,
    align: (auto,auto,auto,auto,),
    [Omnibus:], [0.909], [Durbin-Watson:], [1.548],
    [Prob(Omnibus):], [0.635], [Jarque-Bera (JB):], [0.912],
    [Skew:], [0.031], [Prob(JB):], [0.634],
    [Kurtosis:], [2.577], [Cond. No.], [13.2],
  )]
  , kind: table
  )

\
\
Notes: \
\[1\] Standard Errors assume that the covariance matrix of the errors is
correctly specified.
]
] <e2fa507e>
In the regression output, focus first on:

- `coef`: the estimated intercept and slope.
- `std err`: the standard error of each coefficient estimate.
- `t`: the t statistic for testing whether a coefficient equals zero.
- `P>|t|`: the two-sided p-value for that t test.
- `R-squared`: the proportion of variation in the outcome explained by
  the model.

=== 8.5 Visualizing the fitted line
<visualizing-the-fitted-line>
#block[
#block[
#block[
```sourceCode
x_grid = np.linspace(students["study_hours"].min(), students["study_hours"].max(), 100)
X_grid = sm.add_constant(x_grid)
y_hat_grid = model.predict(X_grid)

plt.figure(figsize=(8, 4.5))
plt.scatter(students["study_hours"], students["score"], alpha=0.75)
plt.plot(x_grid, y_hat_grid, linewidth=2)
plt.xlabel("Study hours")
plt.ylabel("Exam score")
plt.title("Fitted simple regression line")
plt.show()
```

] <cb48>
#emph[]
]
#block[
#block[
#figure([#block[
  #box(image(".\\_pandoc_media_undergrad/undergraduate_data_analysis_intro_ai_files/figure-html/fig-regression-line-output-1.png", height: 4.3125in, width: 6.95833in))
  ]],
  caption: [
    Figure~12: Simple linear regression of exam score on study hours.
  ]
)

] <fig-regression-line>
]
] <cell-fig-regression-line>
=== 8.6 Residuals
<residuals>
Residuals are the vertical differences between observed and fitted
values.

#block[
#block[
#block[
```sourceCode
students = students.copy()
students["fitted_score"] = model.fittedvalues
students["residual"] = model.resid
students[["study_hours", "score", "fitted_score", "residual"]].head()
```

] <cb49>
#emph[]
]
#block[
#block[
#figure(
  align(center)[#table(
    columns: 5,
    align: (auto,auto,auto,auto,auto,),
    table.header([], [study\_hours], [score], [fitted\_score], [residual],),
    table.hline(),
    [0], [2.862679], [73.576097], [73.223568], [0.352529],
    [1], [7.130522], [78.855770], [81.187606], [-2.331836],
    [2], [2.783708], [73.972079], [73.076203], [0.895876],
    [3], [5.231253], [87.441127], [77.643461], [9.797666],
    [4], [6.372933], [86.235048], [79.773902], [6.461145],
  )]
  , kind: table
  )

]
]
] <e80d7296>
#block[
#block[
#block[
```sourceCode
sample_points = students.sample(8, random_state=1)

plt.figure(figsize=(8, 4.5))
plt.scatter(students["study_hours"], students["score"], alpha=0.35)
plt.plot(x_grid, y_hat_grid, linewidth=2)

for _, row in sample_points.iterrows():
    plt.plot(
        [row["study_hours"], row["study_hours"]],
        [row["score"], row["fitted_score"]],
        linewidth=1
    )

plt.xlabel("Study hours")
plt.ylabel("Exam score")
plt.title("Selected residuals")
plt.show()
```

] <cb50>
#emph[]
]
#block[
#block[
#figure([#block[
  #box(image(".\\_pandoc_media_undergrad/undergraduate_data_analysis_intro_ai_files/figure-html/fig-residual-example-output-1.png", height: 4.3125in, width: 6.95833in))
  ]],
  caption: [
    Figure~13: Residuals are vertical distances from observed points to
    the fitted line.
  ]
)

] <fig-residual-example>
]
] <cell-fig-residual-example>
=== 8.7 Regression inference for the slope
<regression-inference-for-the-slope>
A common #strong[hypothesis] test in simple regression is:

\\\[ H\_0: \\beta\_1 = 0 \\\]

\\\[ H\_A: \\beta\_1 \\ne 0 \\\]

If \\(\\beta\_1 = 0\\), the model says there is no linear association
between \\(X\\) and the expected value of \\(Y\\).

The t statistic is:

\\\[ t = \\frac{\\hat{\\beta}\_1 - 0}{SE(\\hat{\\beta}\_1)}. \\\]

#block[
#block[
#block[
```sourceCode
model.params
```

] <cb51>
#emph[]
]
#block[
```
const          67.881644
study_hours     1.866057
dtype: float64
```

]
] <4fe86ff1>
#block[
#block[
#block[
```sourceCode
model.bse
```

] <cb53>
#emph[]
]
#block[
```
const          1.372179
study_hours    0.213405
dtype: float64
```

]
] <1fd4b4d1>
#block[
#block[
#block[
```sourceCode
model.pvalues
```

] <cb55>
#emph[]
]
#block[
```
const          9.489645e-81
study_hours    1.829390e-14
dtype: float64
```

]
] <2946a54a>
#block[
#block[
#block[
```sourceCode
model.conf_int(alpha=0.05)
```

] <cb57>
#emph[]
]
#block[
#block[
#figure(
  align(center)[#table(
    columns: 3,
    align: (auto,auto,auto,),
    table.header([], [0], [1],),
    table.hline(),
    [const], [65.164356], [70.598933],
    [study\_hours], [1.443456], [2.288658],
  )]
  , kind: table
  )

]
]
] <425dcf9c>
The p-value for the slope tests evidence against a zero linear
relationship. It does not prove that study hours cause higher scores.
Students who study more may also differ in preparation, motivation,
prior knowledge, attendance, or other #strong[variables].

=== 8.8 Prediction
<prediction>
Regression can be used for prediction. For example, predict the expected
score for a student who studied 6 hours.

#block[
#block[
#block[
```sourceCode
new_data = pd.DataFrame({"const": [1], "study_hours": [6]})
model.predict(new_data)
```

] <cb58>
#emph[]
]
#block[
```
0    79.077987
dtype: float64
```

]
] <92ff6086>
Statsmodels can also produce #strong[confidence intervals] for the
expected mean response and prediction intervals for individual outcomes.

#block[
#block[
#block[
```sourceCode
new_data = sm.add_constant(pd.DataFrame({"study_hours": [2, 4, 6, 8, 10]}), has_constant="add")
pred = model.get_prediction(new_data).summary_frame(alpha=0.05)
pred
```

] <cb60>
#emph[]
]
#block[
#block[
#figure(
  align(center)[#table(
    columns: 7,
    align: (auto,auto,auto,auto,auto,auto,auto,),
    table.header([], [mean], [mean\_se], [mean\_ci\_lower], [mean\_ci\_upper], [obs\_ci\_lower], [obs\_ci\_upper],),
    table.hline(),
    [0], [71.613759], [1.024316], [69.585335], [73.642182], [56.655336], [86.572181],
    [1], [75.345873], [0.761514], [73.837867], [76.853879], [60.449095], [90.242651],
    [2], [79.077987], [0.689145], [77.713291], [80.442682], [64.195033], [93.960940],
    [3], [82.810101], [0.856898], [81.113210], [84.506992], [67.893019], [97.727184],
    [4], [86.542215], [1.165316], [84.234572], [88.849858], [71.543378], [101.541053],
  )]
  , kind: table
  )

]
]
] <71d05d94>
A #strong[confidence interval] for the mean response is narrower than a
prediction interval for a new individual observation. Predicting an
individual outcome is harder than estimating an average outcome.

=== 8.9 Regression assumptions
<regression-assumptions>
#strong[Simple linear regression] is often introduced with these
assumptions:

#block[
#set enum(numbering: "1.", start: 1)
+ #strong[Linearity]: the expected value of \\(Y\\) is a linear function
  of \\(X\\).
+ #strong[Independence]: observations are independent.
+ #strong[Constant variance]: #strong[errors] have the same variance
  across values of \\(X\\).
+ #strong[Approximately normal errors]: mainly important for
  small-sample inference.
+ #strong[No extreme influential points]: a few observations should not
  dominate the fitted line.
]

These assumptions are about the #strong[data-generating process] and the
model #strong[errors], not simply about the observed raw outcome
variable.

=== 8.10 Diagnostic plots
<diagnostic-plots>
#block[
#block[
#block[
```sourceCode
plt.figure(figsize=(8, 4.5))
plt.scatter(model.fittedvalues, model.resid, alpha=0.75)
plt.axhline(0, linestyle="--", linewidth=1)
plt.xlabel("Fitted score")
plt.ylabel("Residual")
plt.title("Residuals versus fitted values")
plt.show()
```

] <cb61>
#emph[]
]
#block[
#block[
#figure([#block[
  #box(image(".\\_pandoc_media_undergrad/undergraduate_data_analysis_intro_ai_files/figure-html/fig-residuals-vs-fitted-output-1.png", height: 4.3125in, width: 6.98958in))
  ]],
  caption: [
    Figure~14: Residuals versus fitted values. Look for curvature,
    changing spread, and unusual points.
  ]
)

] <fig-residuals-vs-fitted>
]
] <cell-fig-residuals-vs-fitted>
#block[
#block[
#block[
```sourceCode
sm.qqplot(model.resid, line="45", fit=True)
plt.title("Normal Q-Q plot of residuals")
plt.show()
```

] <cb62>
#emph[]
]
#block[
#block[
#figure([#block[
  #box(image(".\\_pandoc_media_undergrad/undergraduate_data_analysis_intro_ai_files/figure-html/fig-qq-plot-output-1.png", height: 4.69792in, width: 6.125in))
  ]],
  caption: [
    Figure~15: Normal Q-Q plot of residuals. Large systematic departures
    from the line suggest non-normal errors.
  ]
)

] <fig-qq-plot>
]
] <cell-fig-qq-plot>
=== 8.11 Outliers and influence
<outliers-and-influence>
Outliers in \\(Y\\) and unusual values in \\(X\\) can affect regression.
An observation with an unusual \\(X\\) value has high leverage. A
high-leverage observation can strongly influence the fitted slope if its
\\(Y\\) value does not follow the general pattern.

#block[
#block[
#block[
```sourceCode
x_base = rng.uniform(0, 10, size=40)
y_base = 10 + 2 * x_base + rng.normal(0, 2, size=40)

# Add one influential point
x_infl = np.append(x_base, 18)
y_infl = np.append(y_base, 12)

# Fit models
X_base = sm.add_constant(x_base)
X_infl = sm.add_constant(x_infl)
mod_base = sm.OLS(y_base, X_base).fit()
mod_infl = sm.OLS(y_infl, X_infl).fit()

grid = np.linspace(0, 18, 100)

plt.figure(figsize=(8, 4.5))
plt.scatter(x_base, y_base, alpha=0.75, label="Original data")
plt.scatter([18], [12], marker="x", s=80, label="Influential point")
plt.plot(grid, mod_base.predict(sm.add_constant(grid)), linewidth=2, label="Without point")
plt.plot(grid, mod_infl.predict(sm.add_constant(grid)), linewidth=2, linestyle="--", label="With point")
plt.xlabel("X")
plt.ylabel("Y")
plt.title("Influence in simple regression")
plt.legend()
plt.show()
```

] <cb63>
#emph[]
]
#block[
#block[
#figure([#block[
  #box(image(".\\_pandoc_media_undergrad/undergraduate_data_analysis_intro_ai_files/figure-html/fig-influential-point-output-1.png", height: 4.30208in, width: 6.86458in))
  ]],
  caption: [
    Figure~16: A single high-leverage point can substantially change a
    regression line.
  ]
)

] <fig-influential-point>
]
] <cell-fig-influential-point>
=== 8.12 Correlation and simple regression
<correlation-and-simple-regression>
Correlation measures the strength and direction of a linear association
between two numerical #strong[variables]:

\\\[ r = \\frac{\\sum\_i (x\_i-\\bar{x})(y\_i-\\bar{y})}{\\sqrt{\\sum\_i
(x\_i-\\bar{x})^2\\sum\_i (y\_i-\\bar{y})^2}}. \\\]

Correlation is unitless and lies between -1 and 1. Regression slope has
units: units of \\(Y\\) per one unit of \\(X\\).

#block[
#block[
#block[
```sourceCode
r = students[["study_hours", "score"]].corr().iloc[0, 1]
r
```

] <cb64>
#emph[]
]
#block[
```
np.float64(0.6270516845121317)
```

]
] <6d7ba6ed>
For #strong[simple linear regression] with an intercept,

\\\[ R^2 = r^2. \\\]

#block[
#block[
#block[
```sourceCode
r**2, model.rsquared
```

] <cb66>
#emph[]
]
#block[
```
(np.float64(0.3931938150495019), np.float64(0.393193815049502))
```

]
] <4973a927>
=== 8.13 Regression with a binary predictor
<regression-with-a-binary-predictor>
A two-sample comparison can be written as a regression with a 0/1
predictor.

#block[
#block[
#block[
```sourceCode
X_review = sm.add_constant(students["review_session"])
model_review = sm.OLS(students["score"], X_review).fit()
model_review.summary()
```

] <cb68>
#emph[]
]
#block[
#figure(
  align(center)[#table(
    columns: 4,
    align: (auto,auto,auto,auto,),
    [Dep. Variable:], [score], [R-squared:], [0.102],
    [Model:], [OLS], [Adj. R-squared:], [0.094],
    [Method:], [Least Squares], [F-statistic:], [13.42],
    [Date:], [Tue, 30 Jun 2026], [Prob (F-statistic):], [0.000375],
    [Time:], [02:49:31], [Log-Likelihood:], [-434.31],
    [No. Observations:], [120], [AIC:], [872.6],
    [Df Residuals:], [118], [BIC:], [878.2],
    [Df Model:], [1], [], [],
    [Covariance Type:], [nonrobust], [], [],
  )]
  , caption: [OLS Regression Results]
  , kind: table
  )

#figure(
  align(center)[#table(
    columns: 7,
    align: (auto,auto,auto,auto,auto,auto,auto,),
    [], [coef], [std err], [t], [P\>|t|], [\[0.025], [0.975\]],
    [const], [75.6704], [1.096], [69.044], [0.000], [73.500], [77.841],
    [review\_session], [6.1576], [1.681], [3.663], [0.000], [2.828], [9.487],
  )]
  , kind: table
  )

#figure(
  align(center)[#table(
    columns: 4,
    align: (auto,auto,auto,auto,),
    [Omnibus:], [1.901], [Durbin-Watson:], [1.555],
    [Prob(Omnibus):], [0.387], [Jarque-Bera (JB):], [1.457],
    [Skew:], [0.052], [Prob(JB):], [0.483],
    [Kurtosis:], [2.470], [Cond. No.], [2.48],
  )]
  , kind: table
  )

\
\
Notes: \
\[1\] Standard Errors assume that the covariance matrix of the errors is
correctly specified.
]
] <3875d988>
Here, the intercept is the mean score for the group coded 0, and the
slope is the difference between the group coded 1 and the group coded 0.

#block[
#block[
#block[
```sourceCode
students.groupby("review_session")["score"].mean()
```

] <cb69>
#emph[]
]
#block[
```
review_session
0    75.670367
1    81.827939
Name: score, dtype: float64
```

]
] <b98901d9>
#block[
#block[
#block[
```sourceCode
model_review.params
```

] <cb71>
#emph[]
]
#block[
```
const             75.670367
review_session     6.157571
dtype: float64
```

]
] <9a366a66>
This connection helps unify regression and #strong[hypothesis] testing.
A t-test comparing two means and a regression with one binary predictor
answer closely related questions.

== 9 Case study: studying, review sessions, and exam scores
<case-study-studying-review-sessions-and-exam-scores>
=== 9.1 Research questions
<research-questions>
For the teaching #strong[dataset], suppose we ask:

#block[
#set enum(numbering: "1.", start: 1)
+ Is the average exam score different from 75?
+ Do students who attended the review session have different average
  scores from those who did not?
+ Is study time linearly associated with exam score?
]

=== 9.2 Question 1: one-sample mean test
<question-1-one-sample-mean-test>
#block[
#block[
#block[
```sourceCode
q1 = stats.ttest_1samp(students["score"], popmean=75)
q1
```

] <cb73>
#emph[]
]
#block[
```
TtestResult(statistic=np.float64(3.764101620327317), pvalue=np.float64(0.0002610704768896567), df=np.int64(119))
```

]
] <8d14b49a>
#block[
#block[
#block[
```sourceCode
q1_summary = pd.DataFrame({
    "estimate": [students["score"].mean()],
    "hypothesized_mean": [75],
    "test_statistic": [q1.statistic],
    "p_value": [q1.pvalue]
})
q1_summary
```

] <cb75>
#emph[]
]
#block[
#block[
#figure(
  align(center)[#table(
    columns: 5,
    align: (auto,auto,auto,auto,auto,),
    table.header([], [estimate], [hypothesized\_mean], [test\_statistic], [p\_value],),
    table.hline(),
    [0], [78.287335], [75], [3.764102], [0.000261],
  )]
  , kind: table
  )

]
]
] <e5399af8>
Interpretation template:

#quote(block: true)[
The sample mean exam score is shown in the table. The one-sample t-test
compares this estimate with 75. If the p-value is less than the chosen
#strong[significance level], we reject the null #strong[hypothesis] that
the population mean is 75. The conclusion should be stated as evidence
about the population mean, not as proof about every student.
]

=== 9.3 Question 2: review-session comparison
<question-2-review-session-comparison>
#block[
#block[
#block[
```sourceCode
q2 = stats.ttest_ind(review, no_review, equal_var=False)
q2
```

] <cb76>
#emph[]
]
#block[
```
TtestResult(statistic=np.float64(3.479137071234403), pvalue=np.float64(0.0007966286697875997), df=np.float64(84.80426876919141))
```

]
] <9fd59da4>
#block[
#block[
#block[
```sourceCode
q2_summary = pd.DataFrame({
    "mean_review": [review.mean()],
    "mean_no_review": [no_review.mean()],
    "mean_difference": [review.mean() - no_review.mean()],
    "test_statistic": [q2.statistic],
    "p_value": [q2.pvalue]
})
q2_summary
```

] <cb78>
#emph[]
]
#block[
#block[
#figure(
  align(center)[#table(
    columns: 6,
    align: (auto,auto,auto,auto,auto,auto,),
    table.header([], [mean\_review], [mean\_no\_review], [mean\_difference], [test\_statistic], [p\_value],),
    table.hline(),
    [0], [81.827939], [75.670367], [6.157571], [3.479137], [0.000797],
  )]
  , kind: table
  )

]
]
] <dc2562cf>
Interpretation template:

#quote(block: true)[
The estimated difference in average scores is the review group mean
minus the no-review group mean. Welch's t-test assesses whether this
observed difference would be unusual if the population means were equal.
Because this is observational in the simulated story, a significant
difference should not automatically be interpreted as causal.
]

=== 9.4 Question 3: regression of score on study hours
<question-3-regression-of-score-on-study-hours>
#block[
#block[
#block[
```sourceCode
q3_model = sm.OLS(students["score"], sm.add_constant(students["study_hours"])).fit()
q3_model.summary()
```

] <cb79>
#emph[]
]
#block[
#figure(
  align(center)[#table(
    columns: 4,
    align: (auto,auto,auto,auto,),
    [Dep. Variable:], [score], [R-squared:], [0.393],
    [Model:], [OLS], [Adj. R-squared:], [0.388],
    [Method:], [Least Squares], [F-statistic:], [76.46],
    [Date:], [Tue, 30 Jun 2026], [Prob (F-statistic):], [1.83e-14],
    [Time:], [02:49:31], [Log-Likelihood:], [-410.80],
    [No. Observations:], [120], [AIC:], [825.6],
    [Df Residuals:], [118], [BIC:], [831.2],
    [Df Model:], [1], [], [],
    [Covariance Type:], [nonrobust], [], [],
  )]
  , caption: [OLS Regression Results]
  , kind: table
  )

#figure(
  align(center)[#table(
    columns: 7,
    align: (auto,auto,auto,auto,auto,auto,auto,),
    [], [coef], [std err], [t], [P\>|t|], [\[0.025], [0.975\]],
    [const], [67.8816], [1.372], [49.470], [0.000], [65.164], [70.599],
    [study\_hours], [1.8661], [0.213], [8.744], [0.000], [1.443], [2.289],
  )]
  , kind: table
  )

#figure(
  align(center)[#table(
    columns: 4,
    align: (auto,auto,auto,auto,),
    [Omnibus:], [0.909], [Durbin-Watson:], [1.548],
    [Prob(Omnibus):], [0.635], [Jarque-Bera (JB):], [0.912],
    [Skew:], [0.031], [Prob(JB):], [0.634],
    [Kurtosis:], [2.577], [Cond. No.], [13.2],
  )]
  , kind: table
  )

\
\
Notes: \
\[1\] Standard Errors assume that the covariance matrix of the errors is
correctly specified.
]
] <08d5a14d>
Interpretation template:

#quote(block: true)[
The slope estimates the expected difference in exam score associated
with one additional study hour. The p-value for the slope tests whether
the population linear slope is zero. The #strong[confidence interval]
gives a range of plausible slope values. The model is useful only to the
extent that the linear form and other assumptions are reasonable.
]

== 10 Practical significance, statistical significance, and causality
<practical-significance-statistical-significance-and-causality>
=== 10.1 Statistical significance
<statistical-significance>
A statistically significant result means the observed data would be
relatively unusual under the null #strong[hypothesis], according to the
test model and chosen \\(\\alpha\\).

=== 10.2 Practical significance
<practical-significance>
Practical significance asks whether the effect is large enough to matter
in context.

For example, a 0.2-point increase in exam score may be statistically
significant in a #strong[dataset] with hundreds of thousands of
students, but it may not matter educationally. A 5-point increase may
matter in practice even if a small study lacks enough power to make it
statistically significant.

=== 10.3 Causality
<causality>
Regression and t-tests measure associations unless the study design
supports causal interpretation. Stronger causal claims usually require
randomized experiments, natural experiments, or careful causal designs.

In the teaching #strong[dataset], students were not randomly assigned to
study hours or review sessions. Therefore, differences may reflect
confounding #strong[variables] such as prior preparation or motivation.

== 11 Common mistakes and better alternatives
<common-mistakes-and-better-alternatives>
#figure(
  align(center)[#table(
    columns: (50%, 50%),
    align: (auto,auto,),
    table.header([Mistake], [Better practice],),
    table.hline(),
    [“The p-value is the probability that \\(H\_0\\) is true.”], [Say:
    the p-value is computed assuming \\(H\_0\\) is true.],
    [“Fail to reject means \\(H\_0\\) is proven.”], [Say: the data did
    not provide strong evidence against \\(H\_0\\).],
    [“Statistically significant means important.”], [Report effect sizes
    and context.],
    [“Correlation proves causation.”], [Discuss study design and
    possible confounders.],
    [“The regression line is valid everywhere.”], [Avoid extrapolation
    beyond the data range.],
    [“Model assumptions are optional.”], [Check assumptions and explain
    limitations.],
    [“A non-significant result means no effect.”], [Consider sample
    size, uncertainty, and power.],
  )]
  , kind: table
  )

== 12 Practice exercises
<practice-exercises>
=== 12.1 Exercise 1: probability simulation
<exercise-1-probability-simulation>
Simulate 10,000 samples of 50 coin flips from a fair coin. For each
sample, compute the proportion of heads. Answer:

#block[
#set enum(numbering: "1.", start: 1)
+ What is the mean of the simulated sample proportions?
+ What is their standard deviation?
+ How does this compare with the theoretical standard error
  \\(\\sqrt{p(1-p)/n}\\)?
]

#block[
#block[
#block[
```sourceCode
# Write your code here.
```

] <cb80>
#emph[]
]
] <b5868edc>
=== 12.2 Exercise 2: confidence interval for a mean
<exercise-2-confidence-interval-for-a-mean>
Using the `students` #strong[dataset], compute a 90% #strong[confidence
interval] for the mean exam score. Compare it with the 95% interval.
Which is wider, and why?

#block[
#block[
#block[
```sourceCode
# Write your code here.
```

] <cb81>
#emph[]
]
] <6b102b36>
=== 12.3 Exercise 3: one-sample test
<exercise-3-one-sample-test>
Test whether the average attendance proportion differs from 0.80.

#block[
#set enum(numbering: "1.", start: 1)
+ State \\(H\_0\\) and \\(H\_A\\).
+ Compute the test statistic and p-value.
+ Write a conclusion in context.
]

#block[
#block[
#block[
```sourceCode
# Write your code here.
```

] <cb82>
#emph[]
]
] <427f008f>
=== 12.4 Exercise 4: two-sample test
<exercise-4-two-sample-test>
Compare study hours between students who attended the review session and
those who did not.

#block[
#set enum(numbering: "1.", start: 1)
+ Make a #strong[visualization].
+ Compute group means.
+ Run Welch's t-test.
+ Explain whether a difference in study hours might affect the
  interpretation of the review-session score comparison.
]

#block[
#block[
#block[
```sourceCode
# Write your code here.
```

] <cb83>
#emph[]
]
] <f3e99352>
=== 12.5 Exercise 5: simple regression
<exercise-5-simple-regression>
Fit a #strong[simple linear regression] predicting score from
attendance.

#block[
#set enum(numbering: "1.", start: 1)
+ Interpret the intercept and slope.
+ Report the p-value for the slope.
+ Make a scatterplot with the fitted line.
+ Check residuals versus fitted values.
]

#block[
#block[
#block[
```sourceCode
# Write your code here.
```

] <cb84>
#emph[]
]
] <e0d90cce>
=== 12.6 Exercise 6: prediction and extrapolation
<exercise-6-prediction-and-extrapolation>
Use the regression of score on study hours to predict scores for
students who studied 1, 5, 10, and 20 hours.

#block[
#set enum(numbering: "1.", start: 1)
+ Which predictions are within the observed range of study hours?
+ Which predictions require extrapolation?
+ Why is extrapolation risky?
]

#block[
#block[
#block[
```sourceCode
# Write your code here.
```

] <cb85>
#emph[]
]
] <58f5cd02>
== 13 Selected solutions
<selected-solutions>
=== 13.1 Solution 1
<solution-1>
#block[
#block[
#block[
```sourceCode
B = 10_000
n = 50
p = 0.5
props = rng.binomial(n=1, p=p, size=(B, n)).mean(axis=1)

sim_mean = props.mean()
sim_sd = props.std(ddof=1)
theory_se = np.sqrt(p * (1 - p) / n)

pd.DataFrame({
    "quantity": ["simulated mean", "simulated SD", "theoretical SE"],
    "value": [sim_mean, sim_sd, theory_se]
})
```

] <cb86>
#emph[]
]
#block[
#block[
#figure(
  align(center)[#table(
    columns: 3,
    align: (auto,auto,auto,),
    table.header([], [quantity], [value],),
    table.hline(),
    [0], [simulated mean], [0.499864],
    [1], [simulated SD], [0.070747],
    [2], [theoretical SE], [0.070711],
  )]
  , kind: table
  )

]
]
] <db596a2f>
=== 13.2 Solution 2
<solution-2>
#block[
#block[
#block[
```sourceCode
def mean_ci(x, confidence=0.95):
    x = np.asarray(x)
    n = len(x)
    xbar = x.mean()
    s = x.std(ddof=1)
    se = s / np.sqrt(n)
    alpha = 1 - confidence
    t_star = stats.t.ppf(1 - alpha / 2, df=n - 1)
    return xbar - t_star * se, xbar + t_star * se

ci90 = mean_ci(students["score"], confidence=0.90)
ci95 = mean_ci(students["score"], confidence=0.95)

pd.DataFrame({
    "confidence": [0.90, 0.95],
    "lower": [ci90[0], ci95[0]],
    "upper": [ci90[1], ci95[1]],
    "width": [ci90[1] - ci90[0], ci95[1] - ci95[0]]
})
```

] <cb87>
#emph[]
]
#block[
#block[
#figure(
  align(center)[#table(
    columns: 5,
    align: (auto,auto,auto,auto,auto,),
    table.header([], [confidence], [lower], [upper], [width],),
    table.hline(),
    [0], [0.90], [76.839550], [79.735120], [2.895570],
    [1], [0.95], [76.558037], [80.016633], [3.458595],
  )]
  , kind: table
  )

]
]
] <27c0147b>
The 95% interval is wider because it uses a larger critical value. More
confidence requires allowing a wider range of plausible parameter
values.

=== 13.3 Solution 3
<solution-3>
#block[
#block[
#block[
```sourceCode
stats.ttest_1samp(students["attendance"], popmean=0.80)
```

] <cb88>
#emph[]
]
#block[
```
TtestResult(statistic=np.float64(-1.1254325883068843), pvalue=np.float64(0.26267049769771295), df=np.int64(119))
```

]
] <14f5f7cf>
A two-sided test uses:

\\\[ H\_0: \\mu\_{attendance}=0.80 \\\]

\\\[ H\_A: \\mu\_{attendance}\\ne0.80 \\\]

Interpret the result using the p-value and the sample mean.

#block[
#block[
#block[
```sourceCode
students["attendance"].mean()
```

] <cb90>
#emph[]
]
#block[
```
np.float64(0.7852375866597823)
```

]
] <39730983>
=== 13.4 Solution 4
<solution-4>
#block[
#block[
#block[
```sourceCode
study_review = students.loc[students["review_session"] == 1, "study_hours"]
study_no_review = students.loc[students["review_session"] == 0, "study_hours"]

plt.figure(figsize=(7, 4.5))
plt.boxplot([study_no_review, study_review], tick_labels=["No review", "Review"])
plt.ylabel("Study hours")
plt.title("Study hours by review-session attendance")
plt.show()

pd.DataFrame({
    "group": ["No review", "Review"],
    "mean_study_hours": [study_no_review.mean(), study_review.mean()],
    "sd_study_hours": [study_no_review.std(ddof=1), study_review.std(ddof=1)]
})
```

] <cb92>
#emph[]
]
#block[
#block[
#figure(image(".\\_pandoc_media_undergrad/undergraduate_data_analysis_intro_ai_files/figure-html/cell-66-output-1.png", height: 4.11458in, width: 6.22917in),
  caption: [
  ]
)

]
]
#block[
#block[
#figure(
  align(center)[#table(
    columns: 4,
    align: (auto,auto,auto,auto,),
    table.header([], [group], [mean\_study\_hours], [sd\_study\_hours],),
    table.hline(),
    [0], [No review], [5.125439], [2.755673],
    [1], [Review], [6.186284], [3.689088],
  )]
  , kind: table
  )

]
]
] <0249101e>
#block[
#block[
#block[
```sourceCode
stats.ttest_ind(study_review, study_no_review, equal_var=False)
```

] <cb93>
#emph[]
]
#block[
```
TtestResult(statistic=np.float64(1.7279687619708528), pvalue=np.float64(0.08747550013041099), df=np.float64(88.65824612087795))
```

]
] <e9a0c590>
If review-session attendees also studied more, then the simple
review/no-review score comparison may mix the association with review
attendance and the association with study time.

=== 13.5 Solution 5
<solution-5>
#block[
#block[
#block[
```sourceCode
attendance_model = sm.OLS(students["score"], sm.add_constant(students["attendance"])).fit()
attendance_model.summary()
```

] <cb95>
#emph[]
]
#block[
#figure(
  align(center)[#table(
    columns: 4,
    align: (auto,auto,auto,auto,),
    [Dep. Variable:], [score], [R-squared:], [0.055],
    [Model:], [OLS], [Adj. R-squared:], [0.047],
    [Method:], [Least Squares], [F-statistic:], [6.854],
    [Date:], [Tue, 30 Jun 2026], [Prob (F-statistic):], [0.0100],
    [Time:], [02:49:31], [Log-Likelihood:], [-437.38],
    [No. Observations:], [120], [AIC:], [878.8],
    [Df Residuals:], [118], [BIC:], [884.3],
    [Df Model:], [1], [], [],
    [Covariance Type:], [nonrobust], [], [],
  )]
  , caption: [OLS Regression Results]
  , kind: table
  )

#figure(
  align(center)[#table(
    columns: 7,
    align: (auto,auto,auto,auto,auto,auto,auto,),
    [], [coef], [std err], [t], [P\>|t|], [\[0.025], [0.975\]],
    [const], [66.0377], [4.756], [13.885], [0.000], [56.620], [75.456],
    [attendance], [15.6000], [5.959], [2.618], [0.010], [3.800], [27.400],
  )]
  , kind: table
  )

#figure(
  align(center)[#table(
    columns: 4,
    align: (auto,auto,auto,auto,),
    [Omnibus:], [4.722], [Durbin-Watson:], [1.651],
    [Prob(Omnibus):], [0.094], [Jarque-Bera (JB):], [4.791],
    [Skew:], [0.466], [Prob(JB):], [0.0911],
    [Kurtosis:], [2.701], [Cond. No.], [11.4],
  )]
  , kind: table
  )

\
\
Notes: \
\[1\] Standard Errors assume that the covariance matrix of the errors is
correctly specified.
]
] <f5c8ba67>
#block[
#block[
#block[
```sourceCode
x_grid = np.linspace(students["attendance"].min(), students["attendance"].max(), 100)
y_grid = attendance_model.predict(sm.add_constant(x_grid))

plt.figure(figsize=(8, 4.5))
plt.scatter(students["attendance"], students["score"], alpha=0.75)
plt.plot(x_grid, y_grid, linewidth=2)
plt.xlabel("Attendance proportion")
plt.ylabel("Exam score")
plt.title("Regression of score on attendance")
plt.show()
```

] <cb96>
#emph[]
]
#block[
#block[
#figure(image(".\\_pandoc_media_undergrad/undergraduate_data_analysis_intro_ai_files/figure-html/cell-69-output-1.png", height: 4.3125in, width: 6.95833in),
  caption: [
  ]
)

]
]
] <7aae063c>
#block[
#block[
#block[
```sourceCode
plt.figure(figsize=(8, 4.5))
plt.scatter(attendance_model.fittedvalues, attendance_model.resid, alpha=0.75)
plt.axhline(0, linestyle="--", linewidth=1)
plt.xlabel("Fitted score")
plt.ylabel("Residual")
plt.title("Residuals versus fitted values")
plt.show()
```

] <cb97>
#emph[]
]
#block[
#block[
#figure(image(".\\_pandoc_media_undergrad/undergraduate_data_analysis_intro_ai_files/figure-html/cell-70-output-1.png", height: 4.3125in, width: 7.03125in),
  caption: [
  ]
)

]
]
] <fb7f4720>
=== 13.6 Solution 6
<solution-6>
#block[
#block[
#block[
```sourceCode
new_study = pd.DataFrame({"study_hours": [1, 5, 10, 20]})
new_study_X = sm.add_constant(new_study, has_constant="add")
preds = q3_model.get_prediction(new_study_X).summary_frame()

pd.concat([new_study, preds], axis=1)
```

] <cb98>
#emph[]
]
#block[
#block[
#figure(
  align(center)[#table(
    columns: 8,
    align: (auto,auto,auto,auto,auto,auto,auto,auto,),
    table.header([], [study\_hours], [mean], [mean\_se], [mean\_ci\_lower], [mean\_ci\_upper], [obs\_ci\_lower], [obs\_ci\_upper],),
    table.hline(),
    [0], [1], [69.747701], [1.191850], [67.387513], [72.107889], [54.740690], [84.754713],
    [1], [5], [77.211930], [0.694169], [75.837286], [78.586574], [62.328061], [92.095799],
    [2], [10], [86.542215], [1.165316], [84.234572], [88.849858], [71.543378], [101.541053],
    [3], [20], [105.202786], [3.153003], [98.958982], [111.446591], [89.120964], [121.284609],
  )]
  , kind: table
  )

]
]
] <398c34bb>
#block[
#block[
#block[
```sourceCode
students["study_hours"].min(), students["study_hours"].max()
```

] <cb99>
#emph[]
]
#block[
```
(np.float64(0.9180250638343775), np.float64(17.38498807122733))
```

]
] <7d9b49f4>
Predictions far outside the observed range rely on the assumption that
the same linear relationship continues beyond the data. That assumption
is often unjustified.

== 14 Mini reference: choosing a basic method
<mini-reference-choosing-a-basic-method>
#figure(
  align(center)[#table(
    columns: (33%, 33%, 33%),
    align: (auto,auto,auto,),
    table.header([Data situation], [Common method], [Example null
      hypothesis],),
    table.hline(),
    [One numerical variable, compare mean to a value], [One-sample
    t-test], [\\(\\mu=\\mu\_0\\)],
    [One numerical variable, two independent groups], [Welch two-sample
    t-test], [\\(\\mu\_1-\\mu\_0=0\\)],
    [One numerical variable, paired before/after observations], [Paired
    t-test], [\\(\\mu\_{difference}=0\\)],
    [Two numerical variables], [Correlation or simple
    regression], [\\(\\rho=0\\) or \\(\\beta\_1=0\\)],
    [Numerical outcome and one numerical predictor], [Simple linear
    regression], [\\(\\beta\_1=0\\)],
    [Binary outcome and predictors], [Logistic regression], [coefficient
    equals 0],
  )]
  , kind: table
  )

This table is only a starting point. The right method depends on study
design, measurement, assumptions, and the research question.

== 15 Glossary
<glossary>
#strong[Alternative hypothesis]: the claim compared against the null
#strong[hypothesis], often representing an effect or difference.

#strong[Bias]: systematic error in an estimate or study design.

#strong[Confidence interval]: an interval produced by a method that
captures the true parameter at a stated long-run rate when assumptions
hold.

#strong[Correlation]: a unitless measure of linear association between
two numerical #strong[variables].

#strong[Estimator]: a rule for estimating a population parameter from
sample data.

#strong[Null hypothesis]: a baseline #strong[hypothesis] used to define
the reference distribution for a test statistic.

#strong[p-value]: probability, assuming the null is true, of observing a
test statistic as extreme as or more extreme than the observed
statistic.

#strong[Parameter]: a numerical feature of a population or
#strong[data-generating process].

#strong[Power]: probability that a test rejects the null
#strong[hypothesis] when a specified alternative is true.

#strong[Regression slope]: estimated change in the expected outcome for
a one-unit increase in a predictor.

#strong[Residual]: observed outcome minus fitted outcome.

#strong[Sample]: observed subset of data.

#strong[Sampling distribution]: distribution of a statistic over
repeated samples.

#strong[Standard error]: standard deviation of a statistic's sampling
distribution.

#strong[Statistic]: a numerical summary computed from a sample.

#strong[Type I error]: rejecting a true null #strong[hypothesis].

#strong[Type II error]: failing to reject a false null
#strong[hypothesis].

== 16 Final checklist for students
<final-checklist-for-students>
Before reporting an analysis, ask:

#block[
#set enum(numbering: "1.", start: 1)
+ What is the research question?
+ What are the observational units?
+ What are the outcome and predictor #strong[variables]?
+ What parameter is being estimated or tested?
+ What assumptions does the method require?
+ What is the estimate?
+ What is the uncertainty: standard error, #strong[confidence interval],
  or p-value?
+ Is the effect practically meaningful?
+ Does the study design support a causal interpretation?
+ What limitations should be stated?
]

== 17 Suggested class flow
<suggested-class-flow>
A 75-minute class can use this sequence:

#figure(
  align(center)[#table(
    columns: (40%, 30%, 30%),
    align: (right,auto,auto,),
    table.header(table.cell(align: right)[Time], [Topic], [Activity],),
    table.hline(),
    table.cell(align: right)[10 min], [Probability and random
    variables], [Coin-flip simulation],
    table.cell(align: right)[10 min], [Sampling variability], [Compare
    repeated sample means],
    table.cell(align: right)[15 min], [Confidence intervals], [Compute
    and interpret a mean interval],
    table.cell(align: right)[20 min], [Hypothesis/significance
    testing], [One-sample and two-sample t-tests],
    table.cell(align: right)[15 min], [Simple regression], [Fit and
    interpret score-on-study-hours model],
    table.cell(align: right)[5 min], [Limitations], [Statistical
    significance, practical significance, causality],
  )]
  , kind: table
  )

A longer lab can ask students to complete the exercises and write a
short report using the interpretation templates.

] <quarto-document-content>
