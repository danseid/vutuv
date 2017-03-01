defmodule Vutuv.JobPostingTag do
  use Vutuv.Web, :model
  import Ecto.Query

  schema "job_posting_tags" do
    field :priority, :integer

    belongs_to :job_posting, Vutuv.JobPosting
    belongs_to :tag, Vutuv.Tag

    timestamps()
  end

  @max_important_tags 3

  @max_optional_tags 7

  @max_other_tags 7

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:job_posting_id, :tag_id, :priority])
    |> validate_required([:priority])
    |> unique_constraint(:job_posting_id_tag_id)
    |> validate_max_tags()
  end

  defp validate_max_tags(changeset) do
    priority = get_field(changeset, :priority)
    id = get_field(changeset, :job_posting_id)
    if(priority && id) do
      max = 
        case priority do
          2 -> @max_important_tags
          1 -> @max_optional_tags
          0 -> @max_other_tags
        end
      if(Vutuv.Repo.one(from j in __MODULE__, 
        where: j.job_posting_id == ^id and
          j.priority == ^priority,
        select: count("*")) >= max) do
        add_error(changeset, :priority, "You already have the maximum number of tags in this category")
      else
        changeset
      end
    else
      changeset
    end
  end

  defimpl Phoenix.Param, for: __MODULE__ do
    def to_param(job_posting_tag) do
      Vutuv.Repo.preload(job_posting_tag, [:tag]).tag.slug
    end
  end
end
