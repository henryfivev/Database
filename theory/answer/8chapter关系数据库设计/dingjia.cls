\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{dingjia}[2018/12/08 dingjia book class]
% \RequirePackage[l2tabu, orthodox]{nag} %编译时，给出过时命令和不规范使用警告。


\LoadClass[UTF8, fontset = ubuntu, a4paper, oneside, scheme=chinese, heading = true]{ctexart}

\RequirePackage{iftex}
\ifXeTeX
% LuaLaTeX 没有以下设置，只有XeTeX有。
\XeTeXgenerateactualtext=1
\xeCJKsetup{CJKmath=true}
\xeCJKsetup{xCJKecglue=true}
\fi
% \global\hyphenpenalty=5000
% \global\tolerance=1000

\defaultfontfeatures{Scale=MatchLowercase}

\RequirePackage{amsmath, amssymb, xfrac}
\RequirePackage[math-style=ISO, bold-style=ISO]{unicode-math} %注意，unicode-math与被其认为过时的bm包不兼容，不要\RequirePackage{bm}
% \setmathfont{Libertinus Math}  % 因Libertinus目前的数学字体暂还没
% 有粗体，这里设置为允许伪粗体渲染。
\setmathfont{XITS Math}

% \setmainfont[SlantedFont = {Libertinus Serif Italic}]{Libertinus Serif}
% \setsansfont{TeX Gyre Heros}
% \setmonofont{Libertinus Mono}

\RequirePackage[bodytextleadingratio = 1.68, restoremathleading = true,
footnoteleadingratio = 1.6]{zhlineskip}

\RequirePackage[
    type={CC},
    modifier={by-nc-sa},
    lang=chinese,
    version={4.0},
]{doclicense}

\RequirePackage[backend=biber,style=gb7714-2015,backref=true]{biblatex}
\addbibresource[location=local]{ref/refs.bib}

\defbibheading{bibispart}[\bibname]{%
  \chapter*{#1}%
  \addcontentsline{toc}{part}{#1}%
  \markboth{#1}{#1}}

\renewcommand{\bibfont}{\small}
\renewcommand{\bibauthorfont}{\bfseries\sffamily}%
\renewcommand{\bibtitlefont}{\itshape\color{blue}}%
\renewcommand{\bibpubfont}{\rmfamily\color{violet}}%
\def\UrlFont{\ttfamily}

\RequirePackage{verse}


% 插图所需的宏包
\RequirePackage[table,dvipsnames]{xcolor}
\RequirePackage{graphicx}
\graphicspath{{figures/}}

\RequirePackage{caption}
\DeclareCaptionLabelSeparator{zhspace}{：}
\captionsetup{font=small, labelfont=bf, labelsep = zhspace, format = hang, figureposition=bottom, tableposition=top}
\newcommand{\capsource}[1]{ \vspace{-8pt} \caption*{\mdseries \footnotesize {#1}} } % 自定义图表来源
% 命令，vspace可酌情调整。

\RequirePackage{etoolbox}
% % 脚注按页编号
\RequirePackage{pifont}
\let\oldding\ding% Store old \ding in \oldding
\renewcommand{\ding}[2][1]{\scalebox{#1}{\oldding{#2}}}% Scale \oldding via optional argument

\RequirePackage[perpage, hang, symbol*]{footmisc}
\DefineFNsymbols{cqufnsymbol}{
  {\ding[1.1]{172}}    {\ding[1.1]{173}}
  {\ding[1.1]{174}}    {\ding[1.1]{175}}
  {\ding[1.1]{176}}    {\ding[1.1]{177}}
  {\ding[1.1]{178}}    {\ding[1.1]{179}}
  {\ding[1.1]{180}}    {\ding[1.1]{181}}
}
% 定义footnote的表示方法为cqufnsymbol
\setfnsymbol{cqufnsymbol}
% minipage需要额外定义一行
\renewcommand\thempfootnote{\fnsymbol{mpfootnote}}

\RequirePackage{scrextend}
\deffootnote{0em}{1.6em}{\thefootnotemark\enskip}

\AtBeginEnvironment{quotation}{\kaishu\itshape}


\RequirePackage{ geometry}
\geometry{%
  a4paper,
  heightrounded,
  includemp = false, % includes the margin notes, \marginparwidth and \marginparsep, into body when calculating horizontal calculation.
  inner = 2.2cm,
  outer = 2.2cm,
  % marginparwidth = 80pt,
  top = 2.2cm,
  bottom = 2.2cm,
  headheight = 6mm,
  headsep = 10mm,
  footskip = 10mm,
}

\RequirePackage{fancyhdr}
% \pagestyle{headings}
% \fancyhf{} % clear all header and footer fields
% \lhead{}
% \rhead{}
% \chead{\slshape \zihao{5} \leftmark}
\pagestyle{fancy}
\fancyhf{} % clear all header and footer fields
\fancyhead[LE,RO]{\slshape \small \thepage}
\fancyhead[RE]{\slshape \small \leftmark}
\fancyhead[LO]{\slshape \small \rightmark}
\renewcommand{\headrulewidth}{0.75pt}
\renewcommand{\footrulewidth}{0pt}
\fancyheadoffset{0cm}

\RequirePackage{emptypage} %空白页没有页眉页脚

\setlength\parskip{0em plus 4pt minus 2pt}

\RequirePackage{microtype} % 改善单词、字母间距
% 注意以下设定是为book/article所设，如是beamer的话需要修改。
% from package hyperref
\RequirePackage{hyperref}
% \hypersetup{%
%   colorlinks = true,
%   citecolor=magenta,
%   linkcolor=blue,
%   bookmarksnumbered = true,
%   bookmarksopen = true,
%   pdfcreator = {sd44sd44@yeah.net},
%   pdfauthor = {蛋疼的蛋蛋},
%   % pdfsubject = {丁家庄城中村},
%   % pdfkeywords = {丁家庄, 城中村, 新型城镇化, 社会空间, 社会排斥}
% }


\RequirePackage{pdfpages, pdflscape}
\RequirePackage{siunitx}
\sisetup{
  group-digits=false,
  tight-spacing=true,
  % round-mode=places,
  % round-precision=2,
  % round-integer-to-decimal=true,
  per-mode=symbol,
  detect-all,
}

\RequirePackage[usestackEOL]{stackengine}
\RequirePackage{multirow, tabularx, diagbox}
\RequirePackage{tablefootnote}

\RequirePackage{bookmark}
\RequirePackage{booktabs}
\RequirePackage{lscape}
\RequirePackage{float}

% 双栏排版
\RequirePackage{multicol}
\setlength\columnsep{20pt} % This is the default columnsep for all pages

% 有时候, 浮动的边注在双面模式下会出现在错误的一侧, mparhack 可以修正该问题
% \RequirePackage{mparhack}


% for format of contents
\RequirePackage{tocloft}
\RequirePackage{tocbibind}
\renewcommand\cftdot{…}
\renewcommand{\cftdotsep}{0}
% \renewcommand{\cftsecleader}{\cftdotfill{\cftdotsep}} % ctexart的目录中，section也加点。
% \renewcommand{\cftchapleader}{\cftdotfill{\cftdotsep}} % ctexbook中，chapter也加点。

\renewcommand{\cfttoctitlefont}{\hfill\Large\bfseries}
\renewcommand{\cftaftertoctitle}{\hfill} %使“目录”居中显示，将其中的toc改为lof
% 和lot，则会使浮动体列表和表格列表也居中显示

% \renewcommand{\contentsname}{\hspace*{\fill}\bfseries\Large
% 目录 \hspace*{\fill}}   % 不使用tocloft宏包时也适用的命令。

% 设置目录中各级缩进
% \setlength{\cftsecindent}{2.5em}
\setlength{\cftsubsecindent}{4em}
%
% 使用unicode字体中的单个罗马数字实现
\def\rnum#1{\symbol{\numexpr"216F+#1\relax}}
\def\Rnum#1{\symbol{\numexpr"215F+#1\relax}}
\def\uroman#1{\rnum{\the\value{#1}}}
\def\uRoman#1{\Rnum{\the\value{#1}}}
% \newcommand{\Rnum}[1]{\uppercase\expandafter{\romannumeral #1\relax}}

\RequirePackage[shortlabels]{enumitem}
% \topsep 列表顶部与之前内容的额外空白，不含 \baselineskip
% \partopsep 如果列表之前是一个空行，列表顶部的额外空白
% \itemsep  列表各项之间额外的垂直空白
% \parsep 一个 item 中，如果分段，段落间额外空白
% \leftmargin 列表与左边距之间的水平距离，值为非负
% \rightmargin 列表与右边距之间的水平距离，值为非负
% \itemindent 每一 item 第一行的缩进
% \listparindent 每一 item 第一行之后各行的缩进
% \labelsep 标签盒子与每一 item 第一行文本之间距离
% \labelwidth 标签盒子的宽度；如果标签过长，这一宽度会自动变大，直到列表的第一行文本为止
\setlist{leftmargin= 20pt, itemindent = 20pt, listparindent =
  20pt, %labelindent = 20pt,
  parsep = 0ex, partopsep = 0ex, itemsep = 0.5em }

\setlist[description]{style=standard, font=\large\sffamily\bfseries}

\setlist[2]{labelindent=20pt} % Only the level 2
\setlist[enumerate, 2]{labelindent=20pt} % Only the level 2

% \RequirePackage{tikz, pgfplots}
% \tikzset{every picture/.style={/utils/exec={\footnotesize}}}
% \usetikzlibrary{calc,patterns,decorations.pathreplacing, intersections}
% \usetikzlibrary{arrows,arrows.meta, datavisualization}

% \pgfplotsset{
%   compat=newest,
%   compat/show suggested version=false,
%   tick label style={font=\tiny},
%   label style={font=\small},
%   legend style={font=\footnotesize},
%   label shift=-4pt,
% }

% \newdimen\XCoord
% \newdimen\YCoord

% \newcommand*{\ExtractCoordinate}[1]{\path (#1); \pgfgetlastxy{\XCoord}{\YCoord};}%
% \newcommand*{\LabelCurrentCoordinate}[2]{\fill [#1] ($(\XCoord,\YCoord)$) circle (2pt) node [right] {#2}}%

% \usepackage{tcolorbox}
% \tcbuselibrary{most}


% \newtcolorbox{mybox}[2][]{enhanced jigsaw,fonttitle = \large\sffamily\bfseries, fontupper =
%   \small\itshape, fontlower = \small\itshape, before upper={\parindent=2\ccwd},
%   left=20pt, title=#2,#1}


\RequirePackage{xargs}
\RequirePackage[colorinlistoftodos,prependcaption,textsize=small]{todonotes}
\newcommandx{\unsure}[2][1=]{\todo[inline,linecolor=red,backgroundcolor=red!25,bordercolor=red,#1]{#2}}
\newcommandx{\change}[2][1=]{\todo[inline,linecolor=blue,backgroundcolor=blue!25,bordercolor=blue,#1]{#2}}
\newcommandx{\info}[2][1=]{\todo[inline,linecolor=OliveGreen,backgroundcolor=OliveGreen!25,bordercolor=OliveGreen,#1]{#2}}
\newcommandx{\improve}[2][1=]{\todo[inline,linecolor=Plum,backgroundcolor=Plum!25,bordercolor=Plum,#1]{#2}}
\newcommandx{\thiswillnotshow}[2][1=]{\todo[disable,#1]{#2}}

% \setcounter{secnumdepth}{-2} % Warning: 因为是草稿阶段，为方便观看暂时性不显示章节编号，以后成品时会去掉这行。
\RequirePackage{adjustbox}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 以下设置来源于胡海星的xelatex-zh-book项目
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 默认情况下,LaTeX 要求每页的文字至少占据 20%,否则该页就只单独放置一个浮动环境。而这通常不是我们想要的。我们将这个要求降低到 5%。
\renewcommand*{\textfraction}{0.1}

% 有时如果多个浮动环境连续放在一起, LaTeX 会将它们分在几个不同页,即使它们可在同一
% 页放得下。我们可以通过修改\topfraction 和\bottomfraction分别设置顶端和底端的浮
% 动环境的最大比例。
\renewcommand*{\topfraction}{0.9}
\renewcommand*{\bottomfraction}{0.8}

% 有时 LaTeX 会把一个浮动环境单独放在一页,我们要求这个环境至少要占据 80% 才能单独放在一页。
% 注意: \floatpagefraction 的数值必须小于\topfraction。
\renewcommand*{\floatpagefraction}{0.80}

% 用于产生没有编号但在目次中列出的章。
\newcommand\nchapter[1]{%
 \if@mainmatter%
   \@mainmatterfalse%
   \chapter{#1}%
   \@mainmattertrue%
 \else
   \chapter{#1}%
 \fi
}

\RequirePackage{cleveref}
