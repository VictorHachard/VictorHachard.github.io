---
layout: note
draft: false
date: 2022-06-17 15:31:00 +0200
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