defmodule Anagram.Queue do
  # TODO - why is this slower than non-queue implementation? And WHY WHY does
  # increasing @max_workers slow it down? Would maintaining a worker pool help?
  @max_workers 1

  # This strategy is "go until everything is done". Other possible strategies
  #  - go until enough, then drop everything else on the floor
  #  - go until enough, wait for remaining workers, return answers and partials so we can continue later

  def process(job) do
    spawner_pid = self
    queue_pid = spawn_link fn ->
      manage_queue(spawner_pid, [], [job], 0)
    end
    receive do
      {:results, raw_anagrams} -> raw_anagrams
    end
  end

  def manage_queue(spawner_pid, results, []=_jobs, 0=_worker_count) do
    send(spawner_pid, {:results, results})
  end

  def manage_queue(spawner_pid, results, [job|jobs_t], worker_count) when worker_count < @max_workers do
    queue_pid = self
    spawn_link fn ->
      work(queue_pid, job)
    end
    manage_queue(spawner_pid, results, jobs_t, worker_count + 1)
  end

  def manage_queue(spawner_pid, results, jobs, worker_count) do
    receive do
      {:new_job, job} ->
        manage_queue(spawner_pid, results, [job|jobs], worker_count)
      {:anagram, found} ->
        manage_queue(spawner_pid, [found|results], jobs, worker_count)
      :worker_dead ->
        manage_queue(spawner_pid, results, jobs, worker_count - 1)
    end
  end

  def work(queue_pid, job) do
    job_result = Anagram.process_one_job(job)
    case job_result do
      {:anagram, found} ->
        send(queue_pid, {:anagram, found})
      {:more_jobs, jobs} ->
        Enum.each(jobs, fn (job) ->
          send(queue_pid, {:new_job, job})
        end)
    end
    send(queue_pid, :worker_dead)
  end

end
