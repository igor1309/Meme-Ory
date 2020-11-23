import Foundation

//  MARK: - Take first 100 letters but no more than 3 lines of text. If cut add " ..." to the end

let stories = [
    """
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
    """,
    """
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
    """,
    """
    Lorem ipsum dolor sit amet,
    consectetur adipiscing elit, sed do eiusmod
    """,
    """
    Lorem ipsum dolor sit amet,
    consectetur adipiscing elit,
    sed do eiusmod
    """,
    """
    Lorem ipsum dolor sit amet,
    consectetur adipiscing elit,
    sed do eiusmod tempor
    incididunt ut labore
    """,
    """
    Lorem
    ipsum
    dolor
    sit
    amet,
    consectetur
    adipiscing
    elit
    """
]

func storyText(_ text: String) -> String {
    let maxCount = 100
    let maxLines = 3
    
    var text = text
    if text.count > maxCount {
        text = text.prefix(maxCount).appending(" ...")
    }
    
    let lines = text.components(separatedBy: "\n")
    if lines.count > maxLines {
        text = lines.prefix(maxLines).joined(separator: "\n").appending(" ...")
    }
    
    return text
}

for story in stories {
    print(storyText(story), "\n-----------")
}
