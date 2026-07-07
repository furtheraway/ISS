"""Teaching figures for the Git & GitHub session.

Generates two PNGs into this folder:
  git_three_areas.png   - workspace / index / commit history + the commands between them
  git_local_remote.png  - how a local clone talks to a remote (GitHub) repository

Regenerate with:  python make_git_figures.py
"""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.colors as mcolors
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, FancyArrowPatch, FancyBboxPatch

OUT_DIR = Path(__file__).parent

# -- palette (validated: lightness band, chroma, CVD separation all pass) -----
INK = "#0b0b0b"      # primary text
SEC = "#52514e"      # secondary text
MUT = "#898781"      # muted text
HAIR = "#e1e0d9"     # hairline borders
SURF = "#fcfcfb"     # figure surface
BAND = "#f3f2ee"     # footer band / local-machine panel

BLUE = "#2a78d6"     # workspace
AQUA = "#1baf7a"     # index (staging)
AQUA_D = "#199e70"
YEL = "#eda100"      # commit history
YEL_D = "#c98500"
VIO = "#4a3aa7"      # remote (GitHub)

plt.rcParams.update({
    "font.family": "sans-serif",
    "font.sans-serif": ["Segoe UI", "DejaVu Sans"],
    "font.monospace": ["Consolas", "DejaVu Sans Mono"],
    "text.color": INK,
})


def blend(color, alpha, base="#ffffff"):
    """color at `alpha` opacity over `base`, as hex."""
    c = mcolors.to_rgb(color)
    b = mcolors.to_rgb(base)
    return mcolors.to_hex(tuple(alpha * x + (1 - alpha) * y for x, y in zip(c, b)))


def new_canvas(w, h):
    fig = plt.figure(figsize=(w, h), facecolor=SURF)
    ax = fig.add_axes([0, 0, 1, 1])
    ax.set_xlim(0, w)
    ax.set_ylim(0, h)
    ax.set_aspect("equal")
    ax.axis("off")
    return fig, ax


def rbox(ax, x, y, w, h, fc, ec, lw=2.0, r=0.14, ls="-", z=3):
    ax.add_patch(FancyBboxPatch(
        (x, y), w, h, boxstyle=f"round,pad=0,rounding_size={r}",
        facecolor=fc, edgecolor=ec, linewidth=lw, linestyle=ls, zorder=z))


def arrow(ax, a, b, color=INK, lw=1.8, ls="-", rad=0.0, ms=15, z=3.6,
          style="-|>", conn=None):
    if conn is None:
        conn = f"arc3,rad={rad}"
    ax.add_patch(FancyArrowPatch(
        posA=a, posB=b, arrowstyle=style, connectionstyle=conn,
        mutation_scale=ms, lw=lw, color=color, linestyle=ls,
        shrinkA=2, shrinkB=2, capstyle="round", zorder=z))


def chip(ax, x, y, s, fs=9.5, z=5):
    """A git command on a white pill that sits on top of its arrow."""
    ax.text(x, y, s, ha="center", va="center", fontsize=fs,
            family="monospace", color=INK, zorder=z,
            bbox=dict(boxstyle="round,pad=0.32", fc="white", ec=HAIR, lw=1))


def desc(ax, x, y, s, fs=8.8, color=SEC, z=5, **kw):
    ax.text(x, y, s, ha="center", va="center", fontsize=fs, color=color,
            zorder=z, **kw)


def mini_chip(ax, x, y, s, ec, fs=8, z=6):
    ax.text(x, y, s, ha="center", va="center", fontsize=fs,
            family="monospace", color=INK, zorder=z,
            bbox=dict(boxstyle="round,pad=0.22", fc="white", ec=ec, lw=1.2))


def commit_dots(ax, xs, y, color, r=0.055, z=5):
    ax.plot(xs, [y] * len(xs), color=color, lw=1.6,
            solid_capstyle="round", zorder=z - 0.1)
    for x in xs:
        ax.add_patch(Circle((x, y), r, fc=color, ec="none", zorder=z))


# ============================================================
# Figure 1 - the three areas and the commands between them
# ============================================================
def fig_three_areas():
    fig, ax = new_canvas(12.5, 7.0)

    ax.text(0.45, 6.60, "Git's three areas", fontsize=17,
            fontweight="bold", ha="left", va="center")
    ax.text(0.45, 6.22, "changes move to the right on their way into history; "
            "undo commands copy them back", fontsize=10.5, color=SEC,
            ha="left", va="center")
    ax.text(12.05, 6.60, "solid arrows record changes\ndashed arrows undo them",
            fontsize=8.8, color=MUT, ha="right", va="center")

    # -- the three state boxes ------------------------------------
    boxes = [
        (0.7, BLUE, BLUE, "Workspace", "(working directory)",
         "the project files you\nsee and edit"),
        (5.2, AQUA, AQUA_D, "Index", "(staging area)",
         "the draft of your\nnext commit"),
        (9.7, YEL, YEL_D, "Commit history", "(the repository, .git)",
         "every commit ever\nmade - permanent"),
    ]
    BW, BY0, BY1 = 2.2, 2.55, 4.85
    for x0, hue, edge, title, alt, role in boxes:
        cx = x0 + BW / 2
        rbox(ax, x0, BY0, BW, BY1 - BY0, blend(hue, 0.10), edge, lw=2.2)
        ax.text(cx, 4.42, title, fontsize=13.5, fontweight="bold",
                ha="center", va="center", zorder=6)
        ax.text(cx, 4.10, alt, fontsize=9, color=SEC,
                ha="center", va="center", zorder=6)
        ax.text(cx, 3.62, role, fontsize=9.5, color=SEC, ha="center",
                va="center", zorder=6, linespacing=1.35)
    # bottom detail line of each box
    ax.text(1.8, 2.95, "report.qmd - edited", fontsize=8.5, family="monospace",
            color=MUT, ha="center", va="center", zorder=6)
    ax.text(6.3, 2.95, "report.qmd - staged", fontsize=8.5, family="monospace",
            color=MUT, ha="center", va="center", zorder=6)
    commit_dots(ax, [10.15, 10.6, 11.05, 11.5], 3.0, YEL_D)
    ax.text(11.5, 3.28, "main", fontsize=7.5, color=MUT,
            ha="center", va="center", zorder=6)

    # -- forward arrows (top of the gaps) --------------------------
    arrow(ax, (2.9, 4.35), (5.2, 4.35))
    chip(ax, 4.05, 4.35, "git add <file>")
    desc(ax, 4.05, 3.98, "stage a snapshot of the file")

    arrow(ax, (7.4, 4.35), (9.7, 4.35))
    chip(ax, 8.55, 4.35, 'git commit -m "msg"')
    desc(ax, 8.55, 3.98, "record the index as a new commit")

    # shortcut arc over the top
    arrow(ax, (1.8, 4.85), (10.8, 4.85), rad=-0.25, lw=1.7)
    chip(ax, 6.3, 5.95, 'git commit -a -m "msg"')
    desc(ax, 6.3, 5.55, "shortcut: stage all tracked changes + commit")

    # -- undo arrows (bottom of the gaps) --------------------------
    dash = (0, (4, 2.4))
    arrow(ax, (5.2, 3.0), (2.9, 3.0), color=SEC, lw=1.6, ls=dash)
    chip(ax, 4.05, 3.0, "git restore <file>", fs=9)
    desc(ax, 4.05, 2.63, "discard edits - file matches index", fs=8.6)

    arrow(ax, (9.7, 3.0), (7.4, 3.0), color=SEC, lw=1.6, ls=dash)
    chip(ax, 8.55, 3.0, "git restore --staged <file>", fs=9)
    desc(ax, 8.55, 2.63, "unstage - index matches last commit", fs=8.6)

    # time-travel arc under the bottom
    arrow(ax, (10.8, 2.55), (1.8, 2.55), color=SEC, lw=1.6, ls=dash, rad=0.22)
    chip(ax, 6.3, 1.62, "git switch <branch>")
    desc(ax, 6.3, 1.26, "load a commit into workspace + index  (also: git checkout)")

    # -- footer: inspection commands (change nothing) --------------
    rbox(ax, 0.45, 0.18, 11.6, 0.8, BAND, "none", lw=0, r=0.1, z=1)
    footer = [
        (2.0, "git status", "which files differ where"),
        (4.9, "git diff", "workspace vs index"),
        (7.9, "git diff --staged", "index vs last commit"),
        (10.9, "git log", "browse commit history"),
    ]
    for x, cmd, what in footer:
        ax.text(x, 0.70, cmd, fontsize=10, family="monospace",
                ha="center", va="center", zorder=5)
        ax.text(x, 0.40, what, fontsize=8.5, color=SEC,
                ha="center", va="center", zorder=5)

    out = OUT_DIR / "git_three_areas.png"
    fig.savefig(out, dpi=200, facecolor=fig.get_facecolor())
    plt.close(fig)
    return out


# ============================================================
# Figure 2 - local clone <-> remote (GitHub)
# ============================================================
def fig_local_remote():
    fig, ax = new_canvas(12.5, 7.5)

    ax.text(0.45, 7.08, "Local and remote - how your Git talks to GitHub",
            fontsize=17, fontweight="bold", ha="left", va="center")
    ax.text(0.45, 6.72, "you edit and commit locally; push, fetch and pull "
            "move commits over the network", fontsize=10.5, color=SEC,
            ha="left", va="center")
    ax.text(12.05, 7.08, "dashed = one-time setup", fontsize=8.8, color=MUT,
            ha="right", va="center")

    # -- local machine panel ---------------------------------------
    rbox(ax, 0.5, 1.15, 4.8, 5.15, BAND, "#c3c2b7", lw=1.6, r=0.18, z=2)
    ax.text(2.9, 5.98, "YOUR COMPUTER", fontsize=10.5, fontweight="bold",
            ha="center", va="center", zorder=6)
    ax.text(2.9, 5.66, "local clone - private to you", fontsize=8.8,
            color=SEC, ha="center", va="center", zorder=6)

    # workspace / index / history stack
    rbox(ax, 0.95, 4.5, 3.9, 0.9, blend(BLUE, 0.10), BLUE, lw=2)
    ax.text(2.9, 5.12, "Workspace", fontsize=11.5, fontweight="bold",
            ha="center", va="center", zorder=6)
    ax.text(2.9, 4.78, "the files you edit", fontsize=8.8, color=SEC,
            ha="center", va="center", zorder=6)

    rbox(ax, 0.95, 3.2, 3.9, 0.9, blend(AQUA, 0.10), AQUA_D, lw=2)
    ax.text(2.9, 3.82, "Index", fontsize=11.5, fontweight="bold",
            ha="center", va="center", zorder=6)
    ax.text(2.9, 3.48, "staged changes", fontsize=8.8, color=SEC,
            ha="center", va="center", zorder=6)

    rbox(ax, 0.95, 1.4, 3.9, 1.5, blend(YEL, 0.12), YEL_D, lw=2)
    ax.text(1.15, 2.62, "Commit history (.git)", fontsize=11.5,
            fontweight="bold", ha="left", va="center", zorder=6)
    commit_dots(ax, [1.55, 2.35, 3.15, 3.95], 1.95, YEL_D)
    mini_chip(ax, 3.95, 2.32, "main", YEL_D)
    mini_chip(ax, 3.15, 1.58, "origin/main", VIO)

    # add / commit arrows inside the stack
    arrow(ax, (2.9, 4.5), (2.9, 4.1), color=SEC, lw=1.5, ms=11)
    ax.text(3.08, 4.30, "git add", fontsize=8.5, family="monospace",
            color=SEC, ha="left", va="center", zorder=6)
    arrow(ax, (2.9, 3.2), (2.9, 2.9), color=SEC, lw=1.5, ms=11)
    ax.text(3.08, 3.05, "git commit", fontsize=8.5, family="monospace",
            color=SEC, ha="left", va="center", zorder=6)

    # -- remote panel ----------------------------------------------
    rbox(ax, 7.7, 1.15, 4.4, 5.15, blend(VIO, 0.05), VIO, lw=1.8, r=0.18, z=2)
    ax.text(9.9, 5.98, "GITHUB.COM", fontsize=10.5, fontweight="bold",
            ha="center", va="center", zorder=6)
    ax.text(9.9, 5.66, 'the remote, called "origin" - shared', fontsize=8.8,
            color=SEC, ha="center", va="center", zorder=6)
    desc(ax, 9.55, 4.35, "the shared copy -\nteammates pull from here",
         fs=9, style="italic", linespacing=1.4)

    rbox(ax, 8.15, 1.4, 3.5, 1.5, blend(VIO, 0.08), VIO, lw=2)
    ax.text(8.35, 2.62, "Commit history", fontsize=11.5, fontweight="bold",
            ha="left", va="center", zorder=6)
    commit_dots(ax, [8.85, 9.65, 10.45], 1.95, VIO)
    mini_chip(ax, 10.45, 2.32, "main", VIO)

    # -- network commands ------------------------------------------
    arrow(ax, (4.85, 1.55), (8.15, 1.55), lw=1.8)          # push ->
    chip(ax, 6.5, 1.55, "git push")
    desc(ax, 6.5, 1.21, "publish your new commits", fs=8.6)

    arrow(ax, (8.15, 2.5), (4.85, 2.5), lw=1.8)            # <- fetch
    chip(ax, 6.5, 2.5, "git fetch")
    desc(ax, 6.5, 2.16, "download new commits - updates origin/main only", fs=8.6)

    # pull: remote history -> workspace (elbow up, then left)
    arrow(ax, (10.9, 2.9), (4.85, 4.95), lw=1.8,
          conn="angle,angleA=90,angleB=0,rad=12")
    chip(ax, 6.5, 4.95, "git pull")
    desc(ax, 6.5, 4.59, "fetch + merge: bring teammates' commits into your files",
         fs=8.6)

    # clone: one-time arc underneath
    arrow(ax, (9.9, 1.15), (2.9, 1.15), color=SEC, lw=1.6,
          ls=(0, (4, 2.4)), rad=-0.18)
    chip(ax, 6.4, 0.62, "git clone <url>")
    desc(ax, 6.4, 0.27, "one-time setup - copies the whole repo and links it to origin",
         fs=8.5)

    out = OUT_DIR / "git_local_remote.png"
    fig.savefig(out, dpi=200, facecolor=fig.get_facecolor())
    plt.close(fig)
    return out


if __name__ == "__main__":
    for path in (fig_three_areas(), fig_local_remote()):
        print("wrote", path)
