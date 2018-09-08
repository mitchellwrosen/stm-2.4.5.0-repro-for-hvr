import Data.Foldable
import Control.Concurrent.STM

main :: IO ()
main = do
  -- New queue with capacity 5
  queue <- newTBQueueIO 5

  -- Fill it up with [1..5]
  for_ [1..5] $ \i ->
    atomically (writeTBQueue queue i)

  -- Read 1
  1 <- atomically (readTBQueue queue)

  -- Flush [2..5]
  [2,3,4,5] <- atomically (flushTBQueue queue)

  -- The bug: now the queue capacity is 4, not 5.
  -- To trigger it, first fill up [1..4]...
  for_ [1..4] $ \i ->
    atomically (writeTBQueue queue i)

  -- ... then observe that writing a 5th element fails
  atomically (writeTBQueue queue 5)
