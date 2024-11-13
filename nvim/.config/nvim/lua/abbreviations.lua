function setabbr(filetype, abbr, expr)
	-- vim.cmd('!autocmd')
	vim.cmd("autocmd FileType " .. filetype .. " iabbrev " .. abbr .. " " .. expr)
end

setabbr("java", "sout", "System.out.println")
setabbr("java", "souf", "System.out.printf()<esc>F(a")
setabbr("java", "pcls", 'public class <esc>"%pvbbdbbv^wwdA {<cr>}<esc>O')
setabbr("java", "pint", 'public interface <esc>"%pvbbdbbv^wwdA {<cr>}<esc>O')
setabbr("java", "psvm", "public static void main(String[] args) {<cr>}<esc>O")
setabbr("typescript", "ecls", 'export class <esc>"%pvbbdbbv^wwdA {<cr>}<esc>O')
setabbr("typescript", "eint", 'export interface <esc>"%pvbbdbbv^wwdA {<cr>}<esc>O')
setabbr("python", "defmain", 'def main():<esc>opass<esc>o<cr>if __name__ == "__main__":<esc>omain()')
setabbr(
	"python",
	"deftest",
	'import unittest<esc>o<cr>O<esc>"%pvbbdbbv^dIdef <esc>A():<cr>pass<cr><cr><esc>"%p$vbbdbbv^d,ccIclass Test<esc>l~<esc>A(unittest.TestCase):<cr>def setUp(self):<cr>self.tests = []<cr><cr><esc>"%pvbbdbbv^dI	def test_<esc>A(self):<cr>for value, expected in self.tests:<cr>with self.subTest(value=value):<cr>result = <esc>"%pvbbdbbvT=di <esc>A(value)<cr>print(f"result: {result}, expected: {expected}, input: {value}")<cr>self.assertEqual(result, expected)<cr><cr><esc>0aif __name__ == "__main__":<cr>unittest.main()'
)
setabbr(
	"python",
	"defmn",
	'<cr><esc>"%pvbbdbbv0dviw"lyIdef <esc>A():<cr>pass<cr><cr><esc>d0Idef test_case():<cr>res = <esc>"lpA()<cr>print(res)<cr><cr><esc>d0Idef main():<cr>test_case() # res<cr><cr><esc>d0Iif __name__ == "__main__":<cr>main()'
)
setabbr(
	"lua",
	"lovemain",
	'function love.load()<cr><cr>end<cr><cr>function love.update(dt)<cr><cr>end<cr><cr>function love.keypressed(key)<cr>if key == "escape" then<cr>love.event.quit()<cr>end<cr>end<cr><cr>function love.draw()<cr><cr>end'
)
