## Installition

Clone the repo

```
git clone https://github.com/psdkjoon/mdit.git
```
run the Installition script
```
./install.sh
```

---

## Usage & Options

Run the script from the directory containing the `.mp3` files you want to edit.

```
mdit [options]
```

### Options

| Option | Name | Description | 
 | ----- | ----- | ----- | 
| **(No Option)** | Interactive Mode | The default. Interactively asks you to select which MP3s to modify. | 
| `-s` | Show | Lists the Title, Artist, and Album for all `.mp3` files and exits. No changes are made. | 
| `-ss` | ShowSmall | Lists the Title, Artist, and Album in a *Small* format for all `.mp3` files and exits. No changes are made. | 
| `-a` | All | Automatically selects all `.mp3` files in the directory for modification, skipping the interactive selection. | 
| `-e` | Each | After selecting files, this prompts you for *each file* individually, asking what tag to change and what to change it to. | 
| `-i` | In-place | **DANGER:** Replaces your original files with the modified ones. By default, the script saves new files in a new `mdit_output` folder and leaves your originals untouched. | 
| `-h` | Help | Displays a help message and exits.| 

---

## Workflows & Examples

### Workflow 1: Interactively Select & Batch Edit

This is the most common workflow. You run the script with no options, select your files, and then perform a single "find and replace" action on all of them.

1. Run the script:
   ```
   mdit
   
   ```

2. The script will clear the screen and list your first MP3 file:
   ```
   Some Title by Some Artist from Some Album
   change? [Y/n/f] _
   
   ```

3. Press:
   * `y`, `Y`, or `Enter`: To **mark** the file for changes.
   * `n` or `N`: To **skip** this file.
   * `f` or `F`: To **finish** selecting and move to the editing step.

4. After you press `f`, the script will ask what tag you want to change for all the files you marked:
   ```
   t for Titles
   a for Albums
   r for artists
   What to change? [T/a/r] _
   
   ```

5. After selecting a tag (e.g., `a` for Album), it will ask for a "search" and "replace" term.


   ```
   Enter a search term: (Can use RegEx) Unknown Album
   Enter a replacement term: My Awesome Mixtape
   
   ```

6. The script will process all marked files, applying this change. New, modified files will appear in a folder named `mdit_output`. Your original files are safe.

### Workflow 2: Edit Each File Individually

Use this if you need to make unique changes to each file.

1. Run the script with the `-e` flag:
   ```
   mdit -e
   
   ```

2. Select your files as shown in Workflow 1 (press `y`, `n`, or `f`).

3. After finishing selection, the script will loop through *each file you marked*.

4. For *each file*, it will ask:
   ```
   Some Title by Some Artist from Some Album
   t for Titles
   a for Albums
   r for artists
   What to change? [T/a/r] _
   
   ```

5. After you choose a tag (e.g., `t`), it will prompt you for the new value, pre-filling the old one for easy editing:
   ```
   New Title: Some Title_
   
   ```

6. You will be asked to confirm. This repeats for every file you marked. New files are saved in `mdit_output`.

### Workflow 3: DANGER - In-Place Editing

Use the -i flag **with caution**. This flag modifies your original files. **It is highly recommended to back up your music first.**

The `-i` flag can be combined with other flags.
* `mdit -i`: Interactive selection, changes replace original files.
* `mdit -e -i`: Edit each file individually, changes replace original files.
* `mdit -a -i`: Edit ALL files with one batch rule, changes replace original files.

**Process:**
1. The script still creates new files in `mdit_output` first.
2. **At the very end**, it deletes the *original* files you selected.
3. It then moves the new files from `mdit_output` into your current directory.
4. It removes the (now empty) `mdit_output` directory.

### Workflow 4: Just Show All Tags

This is a read-only operation.

1. Run the script with the `-s` flag:
   ```
   mdit -s
   
   ```

2. The script will print a formatted list of all MP3s and their tags, then exit.
   ```
   =============================
   Track 1 by Cool Artist from Best Album
   ============
   Title: Track 1
   Album: Best Album
   Artist: Cool Artist
   =============================
   Track 2 by Cool Artist from Best Album
   ============
   Title: Track 2
   Album: Best Album
   Artist: Cool Artist
   =============================
   ```
#### OR 
1. Run the script with the `-s` flag:
   ```
   mdit -ss
   
   ```

2. The script will print a *Small* formatted list of all MP3s and their tags, then exit.
   ```
   =============================
   Track 1 by Cool Artist from Best Album
   =============================
   Track 2 by Cool Artist from Best Album
   =============================
   ```

