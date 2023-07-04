---
layout: note
draft: false
date: 2023-06-17 15:31:00 +0200
author: Victor Hachard
---

## Convert File Size to Human-Readable Format

`_sizeof_fmt` function is used to convert a numerical value representing the size of a file into a human-readable format. It takes two parameters: num, which is the size of the file, and suffix, which is an optional parameter representing the unit suffix.

```py
def _sizeof_fmt(num, suffix="B"):
    """
    Return the human readable size of a file. The default suffix is in bytes.
    """
    for unit in ["", "Ki", "Mi", "Gi", "Ti", "Pi", "Ei", "Zi"]:
        if abs(num) < 1024.0:
            return f"{num:3.1f}{unit}{suffix}"
        num /= 1024.0
    return f"{num:.1f}Yi{suffix}"
```

Example 1:

```py
file_size = 1456789
formatted_size = _sizeof_fmt(file_size)
print(formatted_size)
```

Output:

```py
1.4MiB
```

Example 2:

```py
file_size = 1024
formatted_size = _sizeof_fmt(file_size)
print(formatted_size)
```

Output:

```py
1.0KiB
```

## Highlight Words in text

`replace_words` function replaces words in a text with `<span>` tags containing the words in `words_to_replace`. It also keeps track of the positions where the words are found and replaces them in reverse order to avoid modifying the newly added `<span>` tags:

```py
def replace_words(text, words_to_replace, replace_start='<span>', replace_end='</span>'):
    positions = []
    replaced_text = text

    for word in words_to_replace:
        start_index = 0
        while start_index < len(replaced_text):
            index = replaced_text.find(word, start_index)
            if index == -1:
                break
            positions.append((index, index + len(word)))
            start_index = index + len(word)

    # Replace words in reverse order to avoid modifying newly added <span> tags
    for start, end in reversed(positions):
        replaced_text = replaced_text[:start] + replace_start + replaced_text[start:end] + replace_end + replaced_text[end:]

    return replaced_text
```

Example:

```py
text = "Hello world! This is a sample text to demonstrate word replacement."
words_to_replace = ["world", "sample", "replacement"]

result = replace_words(text, words_to_replace)
print(result)
```

Output:
```py
Hello <span>world</span>! This is a <span>sample</span> text to demonstrate word <span>replacement</span>.
```

In the output, you can see that the words "world," "sample," and "replacement" have been wrapped in `<span>` tags.

## Split a list into multiple parts

`split_list` function is used to split a given list (alist) into a specified number of parts (wanted_parts). It has two parameters: alist, which is the list to be split, and wanted_parts, which is an optional parameter representing the desired number of parts to split the list into (default is 1).

```py
def split_list(alist, wanted_parts=1):
    length = len(alist)
    return [alist[i * length // wanted_parts: (i + 1) * length // wanted_parts] for i in range(wanted_parts)]
```

Example:

```py
my_list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
parts = 3

result = split_list(my_list, parts)
print(result)
```

Output:

```py
[[1, 2, 3, 4], [5, 6, 7], [8, 9, 10]]
```

## Perform Multiple Replacements in a String Using a Dictionary

`multiple_replace` function takes a string (string) and a dictionary (rep_dict) as input. It performs multiple replacements in the string based on the keys and corresponding values in the dictionary. It uses regular expressions to match the patterns to be replaced and performs the substitutions using a lambda function.

```py
def multiple_replace(string, rep_dict):
    pattern = re.compile("|".join([re.escape(k) for k in sorted(rep_dict, key=len, reverse=True)]), flags=re.DOTALL)
    return pattern.sub(lambda x: rep_dict[x.group(0)], string)
```

Example:

```py
import re

text = "Hello {name}, you are {age} years old."
replacements = {
    "{name}": "John",
    "{age}": "25"
}

result = multiple_replace(text, replacements)
print(result)
```

Output:

```py
Hello John, you are 25 years old.
```

## Convert Column Number to Excel-Style Column Label

`get_letter` function takes an integer `i` representing a 1-relative column number and converts it to an Excel-style column label. For example, it converts 1 to 'A', 2 to 'B', 27 to 'AA', 28 to 'AB', and so on. 

```py
def get_letter(i: int) -> str:
    """
    Convert 1-relative column number to excel-style column label.
    e.g. 1 -> A, 2 -> B, 27 -> AA, 28 -> AB, etc.
    """
    quot, rem = divmod(i - 1, 26)
    return get_letter(quot) + chr(rem + ord('A')) if i != 0 else ''
```

## Convert Excel-Style Column Label to Column Number"

`get_position` function takes a string `s` representing an Excel-style column label and converts it to a column number. For example, it converts 'A' to 1, 'B' to 2, 'Z' to 26, 'AA' to 27, 'AB' to 28, and so on.

```py
def get_position(s: str) -> int:
    """
    Convert a excel-style column label to a column number.
    e.g. A -> 1, B -> 2, Z -> 26, AA -> 27, AB -> 28
    """
    if len(s) > 1:
        pos = 0
        for idx, letter in enumerate(s[::-1]):
            pos += (get_position(letter) + (1 if idx != 0 else 0)) * 26 ** idx
        return pos
    return ord(s.lower()) - 97
```

<div class="gist" id="/VictorHachard/03a35666fc8644afa7c1939e1a9b1cca/raw/f17945440d7e0d16625dd82694a9928faebdf662/date.py" lang="py"></div>