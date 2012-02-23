# -*- coding: utf-8 -*-
from abc import abstractmethod, ABCMeta
class AbstractReport(object):
  __metaclass__ = ABCMeta
  def __init__(self, data):
    self.data = data

  def output_report(self):
    self._output_header()
    self._output_body()
    self._output_footer()

  @abstractmethod
  def _output_header(self):
    pass

  @abstractmethod
  def _output_body(self):
    pass

  @abstractmethod
  def _output_footer(self):
    pass

class ListReport(AbstractReport):
  def _output_header(self):
    print '<dl>'

  def _output_body(self):
    for d in self.data:
      print '<dd>' + d + '</dd>'

  def _output_footer(self):
    print '</dl>'


class TableReport(AbstractReport):
  def _output_header(self):
    print '<table border="1" cellpadding="2" cellspacing="2">'

  def _output_body(self):
    for d in self.data:
      print '<tr><td>' + d + '</td></tr>'

  def _output_footer(self):
    print '</table>'


# クライアント側のコード
data = ['hoge','fuga','foo']

rep1 = ListReport(data)
rep1.output_report()
# <dl>
# <dd>hoge</dd>
# <dd>fuga</dd>
# <dd>foo</dd>
# </dl>

rep2 = TableReport(data)
rep2.output_report()
# <table border="1" cellpadding="2" cellspacing="2">
# <tr><td>hoge</td></tr>
# <tr><td>fuga</td></tr>
# <tr><td>foo</td></tr>
# </table>


# >>> from abstract_display import *
# >>> data = ['hoge','fuga','foo']
# >>> rep1 = ListReport(data)
# >>> rep1.data
# ['hoge', 'fuga', 'foo']
# >>> rep1.output_report()
# <dl>
# <dd>hoge</dd>
# <dd>fuga</dd>
# <dd>foo</dd>
# </dl>
# >>> rep2 = TableReport(data)
# >>> rep2.output_report()
# <table border="1" cellpadding="2" cellspacing="2">
# <tr><td>hoge</td></tr>
# <tr><td>fuga</td></tr>
# <tr><td>foo</td></tr>
# </table>

