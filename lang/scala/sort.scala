object Sort {
  def main(args: Array[String]) {
    println(quickSort(List(1,3,56,30,9,-3)))
    println(quickSort(List()))
  }

  def quickSort(list: List[Int]): List[Int] = {
    def lower(list: List[Int], p: Int): List[Int] = list.filter(_ < p)
    def upper(list: List[Int], p: Int): List[Int] = list.filter(_ >= p)

    list match {
      case (n::ns) => quickSort(lower(ns, n)) ++ List(n) ++ quickSort(upper(ns, n))
      case List() => List()
    }
  }
}
